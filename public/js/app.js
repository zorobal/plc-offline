/**
 * PLCIOsim Offline - Application JavaScript
 */

// État global
const state = {
    currentProject: null,
    program: { tags: [], rungs: [] },
    isSimulating: false,
    sessionId: Math.random().toString(36).substring(7)
};

// Initialisation
document.addEventListener('DOMContentLoaded', () => {
    initEditor();
    initAI();
});

function initEditor() {
    // Boutons toolbar
    document.getElementById('new-project')?.addEventListener('click', newProject);
    document.getElementById('save-project')?.addEventListener('click', saveProject);
    document.getElementById('run-simulation')?.addEventListener('click', startSimulation);
    document.getElementById('stop-simulation')?.addEventListener('click', stopSimulation);
    document.getElementById('add-rung')?.addEventListener('click', addRung);
    document.getElementById('add-tag')?.addEventListener('click', addTag);
}

function initAI() {
    const modal = document.getElementById('ai-modal');
    const generateBtn = document.getElementById('ai-generate');
    const explainBtn = document.getElementById('ai-explain');
    const debugBtn = document.getElementById('ai-debug');
    const sendBtn = document.getElementById('ai-send');
    const closeBtn = document.getElementById('ai-close');

    generateBtn?.addEventListener('click', () => openAIModal('generate'));
    explainBtn?.addEventListener('click', () => openAIModal('explain'));
    debugBtn?.addEventListener('click', () => openAIModal('debug'));
    sendBtn?.addEventListener('click', sendAIMessage);
    closeBtn?.addEventListener('click', () => modal?.close());
}

// Gestion des projets
async function newProject() {
    if (!confirm('Créer un nouveau projet ? Les modifications non sauvegardées seront perdues.')) return;
    
    state.currentProject = null;
    state.program = { tags: [], rungs: [] };
    renderLadder();
    renderTags();
}

async function saveProject() {
    const title = prompt('Nom du projet :', state.currentProject?.title || 'Nouveau projet');
    if (!title) return;

    try {
        const response = await fetch('/api/projects', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                title,
                description: '',
                program: state.program,
                io_config: { inputs: [], outputs: [] }
            })
        });

        const result = await response.json();
        if (result.success) {
            state.currentProject = { id: result.id, title };
            alert('Projet sauvegardé !');
        } else {
            alert('Erreur: ' + (result.error || 'Échec de la sauvegarde'));
        }
    } catch (error) {
        console.error('Save error:', error);
        alert('Erreur réseau lors de la sauvegarde');
    }
}

// Simulation
function startSimulation() {
    state.isSimulating = true;
    console.log('Simulation démarrée');
    // TODO: Intégrer avec plc-engine.js
}

function stopSimulation() {
    state.isSimulating = false;
    console.log('Simulation arrêtée');
}

// Édition Ladder
function addRung() {
    state.program.rungs.push({
        comment: '',
        instructions: []
    });
    renderLadder();
}

function addTag() {
    const name = prompt('Nom du tag :');
    if (!name) return;
    
    const type = prompt('Type (bool/int/real) :', 'bool');
    const address = prompt('Adresse (%I0.0, %Q0.0, %M0.0) :');
    
    state.program.tags.push({ name, type: type || 'bool', address: address || '' });
    renderTags();
}

function renderLadder() {
    const container = document.getElementById('ladder-container');
    if (!container) return;

    container.innerHTML = state.program.rungs.map((rung, index) => `
        <div class="rung" data-index="${index}">
            <div class="rung-header">
                <span>Rung ${index + 1}</span>
                <input type="text" placeholder="Commentaire..." value="${rung.comment || ''}" 
                       onchange="updateRungComment(${index}, this.value)">
                <button onclick="deleteRung(${index})" class="btn btn-sm btn-danger">×</button>
            </div>
            <div class="rung-instructions">
                ${renderInstructions(rung.instructions)}
            </div>
            <button onclick="addInstruction(${index})" class="btn btn-sm">+ Instruction</button>
        </div>
    `).join('');
}

function renderInstructions(instructions) {
    if (!instructions || instructions.length === 0) {
        return '<em>Aucune instruction</em>';
    }
    return instructions.map((inst, i) => `
        <span class="instruction" data-type="${inst.type}">
            ${inst.type} ${inst.operand || ''}
        </span>
    `).join(' ');
}

function renderTags() {
    const container = document.getElementById('tags-list');
    if (!container) return;

    container.innerHTML = state.program.tags.map((tag, index) => `
        <div class="tag-item">
            <strong>${tag.name}</strong>
            <small>${tag.type}</small>
            <small>${tag.address || '-'}</small>
            <button onclick="deleteTag(${index})" class="btn btn-sm btn-danger">×</button>
        </div>
    `).join('');
}

// Fonctions globales pour les callbacks inline
window.updateRungComment = (index, value) => {
    state.program.rungs[index].comment = value;
};

window.deleteRung = (index) => {
    state.program.rungs.splice(index, 1);
    renderLadder();
};

window.addInstruction = (rungIndex) => {
    const type = prompt('Type d\'instruction (LD, AND, OR, ST, TON, CTU...) :', 'LD');
    if (!type) return;
    
    const operand = prompt('Opérande (nom du tag) :');
    
    state.program.rungs[rungIndex].instructions.push({ type, operand });
    renderLadder();
};

window.deleteTag = (index) => {
    state.program.tags.splice(index, 1);
    renderTags();
};

// IA Functions
let aiMode = 'chat';

function openAIModal(mode = 'chat') {
    aiMode = mode;
    const modal = document.getElementById('ai-modal');
    const title = document.getElementById('ai-modal-title');
    const promptInput = document.getElementById('ai-prompt');

    const titles = {
        chat: 'Assistant IA',
        generate: '🤖 Générer un programme',
        explain: '💡 Expliquer le programme',
        debug: '🔍 Debugger le programme'
    };

    const prompts = {
        chat: 'Posez votre question...',
        generate: 'Décrivez le comportement souhaité...',
        explain: 'Le programme sera automatiquement envoyé',
        debug: 'Décrivez le problème rencontré...'
    };

    title.textContent = titles[mode];
    promptInput.placeholder = prompts[mode];
    
    if (mode === 'explain' || mode === 'debug') {
        promptInput.value = '';
        promptInput.disabled = mode === 'explain';
    }

    modal?.showModal();
}

async function sendAIMessage() {
    const promptInput = document.getElementById('ai-prompt');
    const messagesContainer = document.getElementById('ai-chat-messages');
    const prompt = promptInput.value.trim();

    if (!prompt && aiMode !== 'explain') return;

    // Afficher le message utilisateur
    appendMessage('user', prompt);
    promptInput.value = '';

    try {
        let endpoint = '/api/ai/chat';
        let body = {};

        switch (aiMode) {
            case 'generate':
                endpoint = '/api/ai/generate-ladder?action=generate-ladder';
                body = { description: prompt, session_id: state.sessionId };
                break;
            case 'explain':
                endpoint = '/api/ai/explain?action=explain';
                body = { program: state.program, session_id: state.sessionId };
                break;
            case 'debug':
                endpoint = '/api/ai/debug?action=debug';
                body = { program: state.program, problem: prompt, session_id: state.sessionId };
                break;
            default:
                endpoint = '/api/ai/chat?action=chat';
                body = {
                    messages: [{ role: 'user', content: prompt }],
                    session_id: state.sessionId
                };
        }

        const response = await fetch(endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });

        const result = await response.json();

        if (result.success) {
            let answer = '';
            
            if (result.response) {
                answer = result.response;
            } else if (result.program) {
                answer = 'Programme généré avec succès !';
                state.program = result.program;
                renderLadder();
                renderTags();
            } else if (result.explanation) {
                answer = result.explanation;
            } else if (result.debug) {
                answer = result.debug;
            }

            appendMessage('assistant', answer);
        } else {
            appendMessage('assistant', '❌ Erreur: ' + (result.error || 'Échec de la requête'));
        }
    } catch (error) {
        console.error('AI error:', error);
        appendMessage('assistant', '❌ Erreur réseau: ' + error.message);
    }
}

function appendMessage(role, content) {
    const container = document.getElementById('ai-chat-messages');
    if (!container) return;

    const div = document.createElement('div');
    div.className = `message ${role}`;
    div.textContent = content;
    container.appendChild(div);
    container.scrollTop = container.scrollHeight;
}
