<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= APP_NAME ?> - Éditeur Ladder</title>
    <link rel="stylesheet" href="/public/css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="container">
            <a href="/" class="brand"><?= APP_NAME ?></a>
            <ul class="nav-links">
                <li><a href="/">Éditeur</a></li>
                <li><a href="/projects">Projets</a></li>
                <li><a href="/examples">Exemples</a></li>
                <li><a href="/problems">Challenges</a></li>
                <li><a href="/community">Communauté</a></li>
                <li><a href="/settings">Paramètres</a></li>
                <li><a href="/help">Aide</a></li>
            </ul>
        </div>
    </nav>

    <main class="editor-layout">
        <!-- Sidebar gauche - Tags -->
        <aside class="sidebar tags-panel">
            <h3>Tags</h3>
            <button id="add-tag" class="btn btn-sm">+ Ajouter Tag</button>
            <div id="tags-list"></div>
        </aside>

        <!-- Zone centrale - Éditeur Ladder -->
        <section class="ladder-editor">
            <div class="toolbar">
                <button id="new-project" class="btn">Nouveau</button>
                <button id="save-project" class="btn btn-primary">Sauvegarder</button>
                <button id="run-simulation" class="btn btn-success">▶ Simulation</button>
                <button id="stop-simulation" class="btn btn-danger">■ Stop</button>
                <div class="ai-tools">
                    <button id="ai-generate" class="btn btn-ai">🤖 Générer avec IA</button>
                    <button id="ai-explain" class="btn btn-ai">💡 Expliquer</button>
                    <button id="ai-debug" class="btn btn-ai">🔍 Debugger</button>
                </div>
            </div>
            
            <div id="ladder-container">
                <!-- Les rungs seront générés ici -->
            </div>
            
            <button id="add-rung" class="btn btn-block">+ Ajouter Rung</button>
        </section>

        <!-- Sidebar droite - Simulation & I/O -->
        <aside class="sidebar simulation-panel">
            <h3>Simulation</h3>
            <div id="io-status">
                <div class="io-section">
                    <h4>Entrées</h4>
                    <div id="inputs-list"></div>
                </div>
                <div class="io-section">
                    <h4>Sorties</h4>
                    <div id="outputs-list"></div>
                </div>
            </div>
            
            <div class="scene-container" id="scene-view">
                <!-- Vue 3D/2D de la scène -->
            </div>
        </aside>
    </main>

    <!-- Modal IA -->
    <dialog id="ai-modal" class="modal">
        <div class="modal-content">
            <h3 id="ai-modal-title">Assistant IA</h3>
            <div id="ai-chat-messages"></div>
            <div class="ai-input">
                <textarea id="ai-prompt" placeholder="Décrivez ce que vous voulez..."></textarea>
                <button id="ai-send" class="btn btn-primary">Envoyer</button>
                <button id="ai-close" class="btn">Fermer</button>
            </div>
        </div>
    </dialog>

    <script src="/plc-engine.js"></script>
    <script src="/public/js/app.js"></script>
</body>
</html>
