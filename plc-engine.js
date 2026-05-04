/**
 * PLCIOsim — Moteur de simulation PLC
 * Implémente le scan cycle d'un vrai PLC
 * Tourne dans un Web Worker pour ne pas bloquer l'UI
 */

import { InstructionSet } from './instruction-set.js';
import { TagManager }     from './tag-manager.js';

export class PLCEngine {
    constructor() {
        this.tagManager     = new TagManager();
        this.instructionSet = new InstructionSet();
        this.program        = null;       // Programme Ladder (rungs)
        this.ioState        = {};         // État des I/O physiques (inputs)
        this.outputState    = {};         // État calculé des outputs
        this.timers         = new Map();  // État des timers
        this.counters       = new Map();  // État des counters
        this.scanInterval   = null;
        this.scanCount      = 0;
        this.isRunning      = false;
        this.mode           = 'PROG';     // 'PROG' ou 'RUN'
        this.scanCycleMs    = 50;
    }

    /**
     * Charger un programme
     */
    loadProgram(program) {
        this.stopScan();
        this.program    = program;
        this.timers     = new Map();
        this.counters   = new Map();
        this.scanCount  = 0;

        // Initialiser les tags
        this.tagManager.clear();
        if (program?.tags) {
            for (const tag of program.tags) {
                this.tagManager.createTag(tag.name, tag.type, 0);
            }
        }

        // Synchroniser l'état I/O
        this.syncIOToTags();
    }

    /**
     * Démarrer le scan cycle
     */
    startScan() {
        if (this.isRunning || !this.program) return;
        this.isRunning = true;
        this.mode      = 'RUN';
        this.scanInterval = setInterval(() => this.scan(), this.scanCycleMs);
    }

    /**
     * Arrêter le scan cycle
     */
    stopScan() {
        if (!this.isRunning) return;
        this.isRunning = false;
        this.mode      = 'PROG';
        if (this.scanInterval) {
            clearInterval(this.scanInterval);
            this.scanInterval = null;
        }
    }

    /**
     * Un scan cycle complet
     * ┌─────────────────────────────────┐
     * │ 1. Read Inputs                  │
     * │ 2. Execute Program              │
     * │ 3. Write Outputs                │
     * │ 4. Housekeeping (timers/count.) │
     * └─────────────────────────────────┘
     */
    scan() {
        const startTime = performance.now();

        // ── PHASE 1 : Read Inputs ────────────────
        this.readInputs();

        // ── PHASE 2 : Execute Program ────────────
        if (this.program?.rungs) {
            for (const rung of this.program.rungs) {
                this.executeRung(rung);
            }
        }

        // ── PHASE 3 : Write Outputs ──────────────
        this.writeOutputs();

        // ── PHASE 4 : Housekeeping ───────────────
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
     * Phase 1 — Lire les inputs physiques vers la table des tags
     */
    readInputs() {
        for (const [tag, value] of Object.entries(this.ioState)) {
            this.tagManager.setTag(tag, value);
        }
    }

    /**
     * Phase 2 — Exécuter un rung
     */
    executeRung(rung) {
        if (!rung.instructions || rung.instructions.length === 0) return;

        // Construire la matrice de contacts du rung
        const matrix = this.buildRungMatrix(rung.instructions);

        // Évaluer le power flow (gauche → droite)
        const rungPower = this.evaluateMatrix(matrix);

        // Exécuter les instructions de sortie
        for (const instr of rung.instructions) {
            if (this.isOutputInstruction(instr.type)) {
                this.executeOutputInstruction(instr, rungPower, rung);
            }
        }
    }

    /**
     * Construire la matrice parallèle/série d'un rung
     * Les instructions sur la même row sont en SÉRIE (AND)
     * Les instructions sur des rows différentes sont en PARALLÈLE (OR)
     */
    buildRungMatrix(instructions) {
        const contactInstructions = instructions.filter(i => this.isContactInstruction(i.type));

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
     * Évaluer la matrice — retourne true si le rung est energized
     */
    evaluateMatrix(matrix) {
        if (matrix.length === 0) return false;

        // Chaque row est une branche parallèle
        // La branche est true si toutes ses instructions sont true (série/AND)
        return matrix.some(row => {
            if (row.length === 0) return false;
            return row.every(instr => this.evaluateContactInstruction(instr));
        });
    }

    /**
     * Évaluer une instruction contact
     */
    evaluateContactInstruction(instr) {
        const tag   = instr.tag;
        const value = this.tagManager.getTag(tag);

        switch (instr.type) {
            case 'XIC': // Normally Open — true si tag = 1
                return value === 1 || value === true;

            case 'XIO': // Normally Closed — true si tag = 0
                return value === 0 || value === false;

            case 'OSR': { // One Shot Rising
                const key    = `osr_${instr.tag}_${instr._id}`;
                const prev   = this.tagManager.getInternal(key) ?? 0;
                const curr   = value ? 1 : 0;
                this.tagManager.setInternal(key, curr);
                return (curr === 1 && prev === 0);
            }

            case 'OSF': { // One Shot Falling
                const key    = `osf_${instr.tag}_${instr._id}`;
                const prev   = this.tagManager.getInternal(key) ?? 0;
                const curr   = value ? 1 : 0;
                this.tagManager.setInternal(key, curr);
                return (curr === 0 && prev === 1);
            }

            // Compare instructions
            case 'EQU': return this.resolveValue(instr.sourceA) === this.resolveValue(instr.sourceB);
            case 'NEQ': return this.resolveValue(instr.sourceA) !== this.resolveValue(instr.sourceB);
            case 'LES': return this.resolveValue(instr.sourceA) <   this.resolveValue(instr.sourceB);
            case 'LEQ': return this.resolveValue(instr.sourceA) <=  this.resolveValue(instr.sourceB);
            case 'GRT': return this.resolveValue(instr.sourceA) >   this.resolveValue(instr.sourceB);
            case 'GEQ': return this.resolveValue(instr.sourceA) >=  this.resolveValue(instr.sourceB);

            // Timer/Counter bits (ex: T1.DN, C1.DN, T1.TT)
            default: {
                if (tag.includes('.')) {
                    const [name, bit] = tag.split('.');
                    const timer   = this.timers.get(name);
                    const counter = this.counters.get(name);
                    const obj     = timer ?? counter;
                    if (obj) return obj[bit] ?? false;
                }
                return false;
            }
        }
    }

    /**
     * Exécuter une instruction de sortie
     */
    executeOutputInstruction(instr, rungPower, rung) {
        switch (instr.type) {
            case 'OTE': // Output Energize
                this.tagManager.setTag(instr.tag, rungPower ? 1 : 0);
                break;

            case 'OTL': // Output Latch — ne se désactive QUE via OTU
                if (rungPower) this.tagManager.setTag(instr.tag, 1);
                break;

            case 'OTU': // Output Unlatch
                if (rungPower) this.tagManager.setTag(instr.tag, 0);
                break;

            case 'TON': { // Timer On-Delay
                const timer = this.timers.get(instr.tag) ?? {
                    acc: 0, en: false, dn: false, tt: false, preset: instr.preset ?? 1000
                };
                timer.en = rungPower;
                if (!rungPower) {
                    timer.acc = 0;
                    timer.dn  = false;
                    timer.tt  = false;
                }
                this.timers.set(instr.tag, timer);
                break;
            }

            case 'TOF': { // Timer Off-Delay
                const timer = this.timers.get(instr.tag) ?? {
                    acc: 0, en: false, dn: false, tt: false, preset: instr.preset ?? 1000
                };
                timer.en = rungPower;
                if (rungPower) {
                    timer.acc = 0;
                    timer.dn  = true;
                }
                this.timers.set(instr.tag, timer);
                break;
            }

            case 'CTU': { // Count Up
                const counter = this.counters.get(instr.tag) ?? {
                    acc: 0, dn: false, cu: false, preset: instr.preset ?? 10
                };
                const prevCU = counter.cu;
                counter.cu   = rungPower;
                if (rungPower && !prevCU) { // Rising edge
                    counter.acc++;
                    if (counter.acc >= counter.preset) counter.dn = true;
                }
                this.counters.set(instr.tag, counter);
                break;
            }

            case 'CTD': { // Count Down
                const counter = this.counters.get(instr.tag) ?? {
                    acc: 0, dn: false, cd: false, preset: instr.preset ?? 10
                };
                const prevCD = counter.cd;
                counter.cd   = rungPower;
                if (rungPower && !prevCD && counter.acc > 0) {
                    counter.acc--;
                    counter.dn = counter.acc <= 0;
                }
                this.counters.set(instr.tag, counter);
                break;
            }

            case 'RES': { // Reset timer ou counter
                if (rungPower) {
                    if (this.timers.has(instr.tag)) {
                        const t = this.timers.get(instr.tag);
                        t.acc = 0; t.dn = false; t.tt = false;
                    }
                    if (this.counters.has(instr.tag)) {
                        const c = this.counters.get(instr.tag);
                        c.acc = 0; c.dn = false;
                    }
                }
                break;
            }

            // Math instructions
            case 'ADD': if (rungPower) this.tagManager.setTag(instr.dest, this.resolveValue(instr.sourceA) + this.resolveValue(instr.sourceB)); break;
            case 'SUB': if (rungPower) this.tagManager.setTag(instr.dest, this.resolveValue(instr.sourceA) - this.resolveValue(instr.sourceB)); break;
            case 'MUL': if (rungPower) this.tagManager.setTag(instr.dest, this.resolveValue(instr.sourceA) * this.resolveValue(instr.sourceB)); break;
            case 'DIV': if (rungPower && this.resolveValue(instr.sourceB) !== 0) this.tagManager.setTag(instr.dest, this.resolveValue(instr.sourceA) / this.resolveValue(instr.sourceB)); break;
            case 'MOV': if (rungPower) this.tagManager.setTag(instr.dest, this.resolveValue(instr.source)); break;
        }
    }

    /**
     * Phase 3 — Écrire les outputs vers l'état physique
     */
    writeOutputs() {
        this.outputState = {};
        const allTags = this.tagManager.getAllTags();
        for (const [name, value] of Object.entries(allTags)) {
            this.outputState[name] = value;
        }
        // Ajouter l'état des timers/counters
        for (const [name, timer] of this.timers) {
            this.outputState[`${name}.EN`] = timer.en ? 1 : 0;
            this.outputState[`${name}.DN`] = timer.dn ? 1 : 0;
            this.outputState[`${name}.TT`] = timer.tt ? 1 : 0;
            this.outputState[`${name}.ACC`] = timer.acc;
        }
        for (const [name, counter] of this.counters) {
            this.outputState[`${name}.DN`]  = counter.dn  ? 1 : 0;
            this.outputState[`${name}.ACC`] = counter.acc;
        }
    }

    /**
     * Phase 4 — Mettre à jour les timers (accumulation)
     */
    updateTimers() {
        for (const [name, timer] of this.timers) {
            if (timer.en) {
                timer.acc += this.scanCycleMs;
                timer.tt   = !timer.dn;
                if (timer.acc >= timer.preset) {
                    timer.acc = timer.preset;
                    timer.dn  = true;
                    timer.tt  = false;
                }
            }
        }
    }

    /**
     * Mettre à jour l'état d'un I/O (depuis le panneau I/O)
     */
    updateIO(tag, value) {
        this.ioState[tag] = value;
        if (!this.isRunning) {
            // En mode PROG, mise à jour immédiate
            this.tagManager.setTag(tag, value);
        }
    }

    /**
     * Synchroniser les I/O avec les tags
     */
    syncIOToTags() {
        for (const [tag, value] of Object.entries(this.ioState)) {
            this.tagManager.setTag(tag, value);
        }
    }

    /**
     * Helpers
     */
    isContactInstruction(type) {
        return ['XIC','XIO','OSR','OSF','EQU','NEQ','LES','LEQ','GRT','GEQ'].includes(type);
    }

    isOutputInstruction(type) {
        return ['OTE','OTL','OTU','TON','TOF','RTO','CTU','CTD','RES','ADD','SUB','MUL','DIV','MOV'].includes(type);
    }

    resolveValue(source) {
        if (typeof source === 'number') return source;
        if (typeof source === 'string') {
            return this.tagManager.getTag(source) ?? 0;
        }
        return 0;
    }

    getFullState() {
        return {
            tags:     this.tagManager.getAllTags(),
            io:       this.ioState,
            outputs:  this.outputState,
            timers:   Object.fromEntries(this.timers),
            counters: Object.fromEntries(this.counters),
        };
    }

    reset() {
        this.stopScan();
        this.timers     = new Map();
        this.counters   = new Map();
        this.scanCount  = 0;
        this.ioState    = {};
        this.outputState = {};
        this.tagManager.clear();
    }
}
