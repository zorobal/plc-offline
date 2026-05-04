/**
 * PLCIOsim — Moteur de simulation PLC
 * Implémente le scan cycle d'un automate programmable industriel (API/PLC)
 * Conçu pour fonctionner dans un Web Worker afin de ne pas bloquer l'interface utilisateur
 * 
 * @example
 * const engine = new PLCEngine({ scanCycleMs: 50 });
 * engine.loadProgram(program);
 * engine.startScan();
 */

import { InstructionSet } from './instruction-set.js';
import { TagManager }     from './tag-manager.js';

// Constantes de configuration
const DEFAULT_SCAN_CYCLE_MS = 50;
const DEFAULT_TIMER_PRESET  = 1000;
const DEFAULT_COUNTER_PRESET = 10;
const SCAN_MODE = {
    PROGRAM: 'PROG',
    RUN: 'RUN'
};

// Types d'instructions
const CONTACT_INSTRUCTIONS = ['XIC', 'XIO', 'OSR', 'OSF', 'EQU', 'NEQ', 'LES', 'LEQ', 'GRT', 'GEQ'];
const OUTPUT_INSTRUCTIONS  = ['OTE', 'OTL', 'OTU', 'TON', 'TOF', 'RTO', 'CTU', 'CTD', 'RES', 'ADD', 'SUB', 'MUL', 'DIV', 'MOV'];

export class PLCEngine {
    /**
     * @param {Object} options - Options de configuration
     * @param {number} options.scanCycleMs - Durée du cycle de scan en millisecondes (défaut: 50)
     * @param {TagManager} options.tagManager - Gestionnaire de tags personnalisé (optionnel)
     * @param {InstructionSet} options.instructionSet - Jeu d'instructions personnalisé (optionnel)
     */
    constructor(options = {}) {
        this.tagManager     = options.tagManager ?? new TagManager();
        this.instructionSet = options.instructionSet ?? new InstructionSet();
        this.program        = null;
        this.ioState        = {};
        this.outputState    = {};
        this.timers         = new Map();
        this.counters       = new Map();
        this.scanInterval   = null;
        this.scanCount      = 0;
        this.isRunning      = false;
        this.mode           = SCAN_MODE.PROGRAM;
        this.scanCycleMs    = options.scanCycleMs ?? DEFAULT_SCAN_CYCLE_MS;
    }

    /**
     * Charger un programme ladder dans le moteur
     * @param {Object} program - Programme contenant tags et rungs
     * @param {Array} program.tags - Liste des tags à créer
     * @param {Array} program.rungs - Liste des rungs à exécuter
     */
    loadProgram(program) {
        this.stopScan();
        this.program   = program;
        this.timers    = new Map();
        this.counters  = new Map();
        this.scanCount = 0;

        this.tagManager.clear();
        
        if (program?.tags) {
            for (const tag of program.tags) {
                this.tagManager.createTag(tag.name, tag.type, 0);
            }
        }

        this.syncIOToTags();
    }

    /**
     * Démarrer le cycle de scan PLC
     * @throws {Error} Si aucun programme n'est chargé
     */
    startScan() {
        if (this.isRunning || !this.program) return;
        
        this.isRunning = true;
        this.mode      = SCAN_MODE.RUN;
        this.scanInterval = setInterval(() => this.scan(), this.scanCycleMs);
    }

    /**
     * Arrêter le cycle de scan PLC
     */
    stopScan() {
        if (!this.isRunning) return;
        
        this.isRunning = false;
        this.mode      = SCAN_MODE.PROGRAM;
        
        if (this.scanInterval) {
            clearInterval(this.scanInterval);
            this.scanInterval = null;
        }
    }

    /**
     * Exécuter un cycle de scan PLC complet
     * 
     * Phases du cycle :
     * 1. Lecture des entrées physiques
     * 2. Exécution du programme ladder
     * 3. Écriture des sorties
     * 4. Mise à jour interne (timers, compteurs)
     * 
     * @returns {Object} Résultat du scan contenant le compteur, temps d'exécution et état complet
     */
    scan() {
        const startTime = performance.now();

        this.readInputs();
        this.executeProgram();
        this.writeOutputs();
        this.updateTimers();

        this.scanCount++;
        const scanTime = performance.now() - startTime;

        return {
            scanCount:  this.scanCount,
            scanTimeMs: scanTime,
            ioState:    this.getFullState(),
        };
    }

    /**
     * Phase 1 — Lire les états des entrées physiques et mettre à jour les tags
     */
    readInputs() {
        for (const [tag, value] of Object.entries(this.ioState)) {
            this.tagManager.setTag(tag, value);
        }
    }

    /**
     * Phase 2 — Exécuter tous les rungs du programme
     */
    executeProgram() {
        if (!this.program?.rungs) return;

        for (const rung of this.program.rungs) {
            this.executeRung(rung);
        }
    }

    /**
     * Exécuter un rung ladder individuel
     * @param {Object} rung - Rung contenant les instructions
     * @param {Array} rung.instructions - Liste des instructions du rung
     */
    executeRung(rung) {
        if (!rung.instructions || rung.instructions.length === 0) return;

        const matrix = this.buildRungMatrix(rung.instructions);
        const rungPower = this.evaluateMatrix(matrix);

        for (const instr of rung.instructions) {
            if (OUTPUT_INSTRUCTIONS.includes(instr.type)) {
                this.executeOutputInstruction(instr, rungPower, rung);
            }
        }
    }

    /**
     * Construire la matrice de contacts d'un rung pour évaluation du power flow
     * 
     * Organisation :
     * - Instructions sur la même row → connectées en SÉRIE (opération AND)
     * - Instructions sur des rows différentes → connectées en PARALLÈLE (opération OR)
     * 
     * @param {Array} instructions - Instructions du rung
     * @returns {Array<Array>} Matrice de contacts organisée par rows
     */
    buildRungMatrix(instructions) {
        const contactInstructions = instructions.filter(i => CONTACT_INSTRUCTIONS.includes(i.type));

        const rows = {};
        for (const instr of contactInstructions) {
            const row = instr.position?.row ?? 0;
            if (!rows[row]) rows[row] = [];
            rows[row].push(instr);
        }

        return Object.values(rows).map(row =>
            row.sort((a, b) => (a.position?.col ?? 0) - (b.position?.col ?? 0))
        );
    }

    /**
     * Évaluer la matrice de contacts pour déterminer l'état énergétique du rung
     * @param {Array<Array>} matrix - Matrice de contacts
     * @returns {boolean} true si le rung est énergisé (power flow présent)
     */
    evaluateMatrix(matrix) {
        if (matrix.length === 0) return false;

        // Évaluation : chaque row (branche parallèle) est testée
        // Une branche est conductrice si tous ses contacts sont fermés (AND)
        // Le rung est conducteur si au moins une branche est conductrice (OR)
        return matrix.some(row =>
            row.length > 0 && row.every(instr => this.evaluateContactInstruction(instr))
        );
    }

    /**
     * Évaluer une instruction de type contact (XIC, XIO, OSR, OSF, comparaisons)
     * @param {Object} instr - Instruction à évaluer
     * @returns {boolean} État logique du contact (true = fermé/conducteur)
     */
    evaluateContactInstruction(instr) {
        const tag   = instr.tag;
        const value = this.tagManager.getTag(tag);

        switch (instr.type) {
            case 'XIC': // Examine If Closed — contact normalement ouvert
                return value === 1 || value === true;

            case 'XIO': // Examine If Open — contact normalement fermé
                return value === 0 || value === false;

            case 'OSR': // One Shot Rising — impulsion sur front montant
                return this._evaluateOneShot(instr, 'rising', value);

            case 'OSF': // One Shot Falling — impulsion sur front descendant
                return this._evaluateOneShot(instr, 'falling', value);

            // Instructions de comparaison
            case 'EQU': return this.resolveValue(instr.sourceA) === this.resolveValue(instr.sourceB);
            case 'NEQ': return this.resolveValue(instr.sourceA) !== this.resolveValue(instr.sourceB);
            case 'LES': return this.resolveValue(instr.sourceA) <   this.resolveValue(instr.sourceB);
            case 'LEQ': return this.resolveValue(instr.sourceA) <=  this.resolveValue(instr.sourceB);
            case 'GRT': return this.resolveValue(instr.sourceA) >   this.resolveValue(instr.sourceB);
            case 'GEQ': return this.resolveValue(instr.sourceA) >=  this.resolveValue(instr.sourceB);

            // Bits de timer/compteur (ex: T1.DN, C1.DN, T1.TT)
            default:
                return this._evaluateTimerCounterBit(tag);
        }
    }

    /**
     * Évaluer un one-shot (front montant ou descendant)
     * @private
     */
    _evaluateOneShot(instr, edgeType, currentValue) {
        const prefix = edgeType === 'rising' ? 'osr' : 'osf';
        const key    = `${prefix}_${instr.tag}_${instr._id}`;
        const prev   = this.tagManager.getInternal(key) ?? 0;
        const curr   = currentValue ? 1 : 0;
        
        this.tagManager.setInternal(key, curr);
        
        return edgeType === 'rising' 
            ? (curr === 1 && prev === 0)
            : (curr === 0 && prev === 1);
    }

    /**
     * Évaluer un bit de timer ou compteur
     * @private
     */
    _evaluateTimerCounterBit(tag) {
        if (!tag.includes('.')) return false;

        const [name, bit] = tag.split('.');
        const obj = this.timers.get(name) ?? this.counters.get(name);
        
        return obj?.[bit] ?? false;
    }

    /**
     * Exécuter une instruction de sortie (bobine, timer, compteur, opération mathématique)
     * @param {Object} instr - Instruction à exécuter
     * @param {boolean} rungPower - État énergétique du rung (true = énergisé)
     * @param {Object} rung - Rung parent contenant l'instruction
     */
    executeOutputInstruction(instr, rungPower, rung) {
        switch (instr.type) {
            case 'OTE': // Output Energize — bobine standard
                this.tagManager.setTag(instr.tag, rungPower ? 1 : 0);
                break;

            case 'OTL': // Output Latch — verrouillage (maintient l'état même si rungPower devient false)
                if (rungPower) this.tagManager.setTag(instr.tag, 1);
                break;

            case 'OTU': // Output Unlatch — déverrouillage
                if (rungPower) this.tagManager.setTag(instr.tag, 0);
                break;

            case 'TON': // Timer On-Delay — temporisation à l'enclenchement
                this._executeTimerOnDelay(instr, rungPower);
                break;

            case 'TOF': // Timer Off-Delay — temporisation au relâchement
                this._executeTimerOffDelay(instr, rungPower);
                break;

            case 'CTU': // Count Up — comptage incrémental
                this._executeCounterUp(instr, rungPower);
                break;

            case 'CTD': // Count Down — comptage décrémental
                this._executeCounterDown(instr, rungPower);
                break;

            case 'RES': // Reset — remise à zéro timer/compteur
                if (rungPower) this._resetTimerOrCounter(instr.tag);
                break;

            // Instructions mathématiques
            case 'ADD': this._executeMathOperation(instr, rungPower, (a, b) => a + b); break;
            case 'SUB': this._executeMathOperation(instr, rungPower, (a, b) => a - b); break;
            case 'MUL': this._executeMathOperation(instr, rungPower, (a, b) => a * b); break;
            case 'DIV': this._executeMathOperation(instr, rungPower, (a, b) => b !== 0 ? a / b : 0); break;
            case 'MOV': if (rungPower) this.tagManager.setTag(instr.dest, this.resolveValue(instr.source)); break;
        }
    }

    /**
     * Exécuter un timer TON (On-Delay)
     * @private
     */
    _executeTimerOnDelay(instr, rungPower) {
        const timer = this.timers.get(instr.tag) ?? {
            acc: 0, en: false, dn: false, tt: false, preset: instr.preset ?? DEFAULT_TIMER_PRESET
        };
        
        timer.en = rungPower;
        
        if (!rungPower) {
            timer.acc = 0;
            timer.dn  = false;
            timer.tt  = false;
        }
        
        this.timers.set(instr.tag, timer);
    }

    /**
     * Exécuter un timer TOF (Off-Delay)
     * @private
     */
    _executeTimerOffDelay(instr, rungPower) {
        const timer = this.timers.get(instr.tag) ?? {
            acc: 0, en: false, dn: false, tt: false, preset: instr.preset ?? DEFAULT_TIMER_PRESET
        };
        
        timer.en = rungPower;
        
        if (rungPower) {
            timer.acc = 0;
            timer.dn  = true;
        }
        
        this.timers.set(instr.tag, timer);
    }

    /**
     * Exécuter un compteur CTU (Count Up)
     * @private
     */
    _executeCounterUp(instr, rungPower) {
        const counter = this.counters.get(instr.tag) ?? {
            acc: 0, dn: false, cu: false, preset: instr.preset ?? DEFAULT_COUNTER_PRESET
        };
        
        const prevCU = counter.cu;
        counter.cu   = rungPower;
        
        // Incrémenter sur front montant
        if (rungPower && !prevCU) {
            counter.acc++;
            if (counter.acc >= counter.preset) counter.dn = true;
        }
        
        this.counters.set(instr.tag, counter);
    }

    /**
     * Exécuter un compteur CTD (Count Down)
     * @private
     */
    _executeCounterDown(instr, rungPower) {
        const counter = this.counters.get(instr.tag) ?? {
            acc: 0, dn: false, cd: false, preset: instr.preset ?? DEFAULT_COUNTER_PRESET
        };
        
        const prevCD = counter.cd;
        counter.cd   = rungPower;
        
        // Décrémenter sur front montant (si valeur > 0)
        if (rungPower && !prevCD && counter.acc > 0) {
            counter.acc--;
            counter.dn = counter.acc <= 0;
        }
        
        this.counters.set(instr.tag, counter);
    }

    /**
     * Réinitialiser un timer ou un compteur
     * @private
     */
    _resetTimerOrCounter(tag) {
        const timer = this.timers.get(tag);
        if (timer) {
            timer.acc = 0;
            timer.dn  = false;
            timer.tt  = false;
        }
        
        const counter = this.counters.get(tag);
        if (counter) {
            counter.acc = 0;
            counter.dn  = false;
        }
    }

    /**
     * Exécuter une opération mathématique
     * @private
     */
    _executeMathOperation(instr, rungPower, operation) {
        if (!rungPower) return;
        
        const sourceA = this.resolveValue(instr.sourceA);
        const sourceB = this.resolveValue(instr.sourceB);
        const result  = operation(sourceA, sourceB);
        
        this.tagManager.setTag(instr.dest, result);
    }

    /**
     * Phase 3 — Écrire les états des tags et timers/counters vers les sorties physiques
     */
    writeOutputs() {
        this.outputState = {};
        
        // Copier tous les tags dans l'état de sortie
        const allTags = this.tagManager.getAllTags();
        for (const [name, value] of Object.entries(allTags)) {
            this.outputState[name] = value;
        }
        
        // Ajouter les bits de statut des timers
        for (const [name, timer] of this.timers) {
            this.outputState[`${name}.EN`]  = timer.en ? 1 : 0;
            this.outputState[`${name}.DN`]  = timer.dn ? 1 : 0;
            this.outputState[`${name}.TT`]  = timer.tt ? 1 : 0;
            this.outputState[`${name}.ACC`] = timer.acc;
        }
        
        // Ajouter les bits de statut des compteurs
        for (const [name, counter] of this.counters) {
            this.outputState[`${name}.DN`]  = counter.dn ? 1 : 0;
            this.outputState[`${name}.ACC`] = counter.acc;
        }
    }

    /**
     * Phase 4 — Mettre à jour l'accumulation des timers actifs
     */
    updateTimers() {
        for (const [, timer] of this.timers) {
            if (!timer.en) continue;
            
            timer.acc += this.scanCycleMs;
            timer.tt = !timer.dn;
            
            if (timer.acc >= timer.preset) {
                timer.acc = timer.preset;
                timer.dn  = true;
                timer.tt  = false;
            }
        }
    }

    /**
     * Mettre à jour l'état d'une entrée physique depuis le panneau I/O
     * @param {string} tag - Nom du tag associé à l'entrée
     * @param {number|boolean} value - Valeur de l'entrée (0/1 ou false/true)
     */
    updateIO(tag, value) {
        this.ioState[tag] = value;
        
        // En mode PROG, mise à jour immédiate des tags
        if (!this.isRunning) {
            this.tagManager.setTag(tag, value);
        }
    }

    /**
     * Synchroniser l'état des entrées physiques avec les tags
     */
    syncIOToTags() {
        for (const [tag, value] of Object.entries(this.ioState)) {
            this.tagManager.setTag(tag, value);
        }
    }

    /**
     * Résoudre une valeur depuis une source (nombre littéral ou référence de tag)
     * @param {string|number} source - Source de la valeur (tag ou nombre)
     * @returns {number} Valeur résolue
     */
    resolveValue(source) {
        if (typeof source === 'number') return source;
        if (typeof source === 'string') {
            return this.tagManager.getTag(source) ?? 0;
        }
        return 0;
    }

    /**
     * Obtenir l'état complet du moteur (tags, E/S, timers, compteurs)
     * @returns {Object} État complet du système
     */
    getFullState() {
        return {
            tags:     this.tagManager.getAllTags(),
            io:       this.ioState,
            outputs:  this.outputState,
            timers:   Object.fromEntries(this.timers),
            counters: Object.fromEntries(this.counters),
        };
    }

    /**
     * Réinitialiser complètement le moteur
     */
    reset() {
        this.stopScan();
        this.timers      = new Map();
        this.counters    = new Map();
        this.scanCount   = 0;
        this.ioState     = {};
        this.outputState = {};
        this.tagManager.clear();
    }
}
