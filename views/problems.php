<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= ucfirst(basename(__FILE__, '.php')) ?> - <?= APP_NAME ?></title>
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

    <main class="container">
        <h1><?= ucfirst(str_replace('.php', '', basename(__FILE__))) ?></h1>
        <p>Page en construction...</p>
    </main>
</body>
</html>
