# Application Excel de Gestion de Restaurant

## 📋 Vue d'ensemble

Cette application Excel professionnelle permet la gestion complète d'un restaurant, incluant:
- Gestion des stocks et matières premières
- Suivi des ventes et chiffre d'affaires
- Gestion des recettes et coûts matières
- Suivi des fournisseurs et achats
- Inventaires périodiques
- Tableaux de bord analytiques

## 🏗️ Architecture

### Structure des fichiers

```
RestaurantManagement/
├── VBA_Modules/
│   ├── Module_Principal.bas      # Navigation et utilitaires
│   ├── Module_Stocks.bas         # Gestion des stocks
│   ├── Module_Ventes.bas         # Gestion des ventes
│   ├── Module_Recettes.bas       # Gestion des recettes
│   ├── Module_Fournisseurs.bas   # Gestion des fournisseurs
│   └── Module_Rapports.bas       # Génération de rapports
├── Data_Files/
│   ├── Données_Produits.xlsx
│   ├── Données_Ventes.xlsx
│   ├── Données_Fournisseurs.xlsx
│   └── Données_Recettes.xlsx
├── Documentation/
│   ├── GUIDE_UTILISATION.md
│   └── CONFIGURATION.md
├── Templates/
│   └── GestionRestaurant_Template.xlsm
└── Reports/
    └── (Rapports générés)
```

### Feuilles Excel principales

1. **Accueil** - Page de navigation principale
2. **Dashboard** - Tableau de bord avec indicateurs clés
3. **Stocks** - Gestion des produits et matières premières
4. **Mouvements_Stock** - Historique des entrées/sorties
5. **Ventes** - Enregistrement des ventes
6. **Recettes** - Fiches techniques des plats
7. **Fournisseurs** - Base de données fournisseurs
8. **Achats** - Historique des commandes
9. **Inventaires** - Suivi des inventaires
10. **Config** - Configuration de l'application

## 🚀 Installation

### Prérequis

- Microsoft Excel 2016 ou version ultérieure
- Activation des macros (fichier .xlsm)
- Windows 10/11 recommandé

### Étapes d'installation

1. Copiez le fichier `GestionRestaurant.xlsm` dans un dossier sécurisé
2. Ouvrez Excel et allez dans `Fichier > Options > Centre de gestion de la confidentialité`
3. Cliquez sur `Paramètres des macros` et sélectionnez `Activer toutes les macros`
4. Ouvrez le fichier `GestionRestaurant.xlsm`
5. Autorisez l'exécution des macros lors de l'ouverture

### Configuration initiale

Lors du premier lancement:
- L'application se configure automatiquement
- La date de création et la version sont enregistrées
- Les feuilles de calcul sont initialisées

## 📖 Guide d'utilisation

### Page d'Accueil

La page d'accueil offre:
- Navigation vers tous les modules
- Affichage des alertes importantes
- Accès rapide aux rapports
- Statut du système

### Gestion des Stocks

#### Ajouter un produit
1. Cliquez sur le bouton "Ajouter Produit"
2. Remplissez le formulaire:
   - Référence du produit
   - Nom du produit
   - Catégorie
   - Unité de mesure
   - Prix d'achat et de vente
   - Stock minimum et de sécurité
3. Validez

#### Enregistrer une entrée de stock
1. Cliquez sur "Entrée de Stock"
2. Sélectionnez le produit par son ID
3. Saisissez la quantité reçue
4. Indiquez le numéro de document (facture/bon de commande)
5. Validez

#### Enregistrer une sortie de stock
1. Cliquez sur "Sortie de Stock"
2. Sélectionnez le produit
3. Saisissez la quantité sortie
4. Indiquez la raison (vente, perte, gaspillage)
5. Validez

#### Alertes de stock
- L'application vérifie automatiquement les niveaux de stock
- Trois niveaux d'alerte:
  - 🔴 Rupture totale (stock = 0)
  - 🟠 Stock critique (≤ stock de sécurité)
  - 🟡 Stock minimum atteint (≤ stock minimum)

### Gestion des Ventes

#### Enregistrer une vente
1. Cliquez sur "Nouvelle Vente"
2. Saisissez:
   - Nom du plat/produit
   - Catégorie (Entrée, Plat, Dessert, Boisson)
   - Quantité vendue
   - Prix unitaire
   - Mode de paiement
   - Nom du serveur
3. Validez

Le système calcule automatiquement:
- Le total HT
- La TVA (10% pour la restauration)
- Le total TTC

#### Rapports de ventes

**Rapport journalier:**
- Sélectionnez la date
- Consultez le détail des ventes
- Visualisez le chiffre d'affaires du jour
- Nombre de ventes réalisées

**Analyse des performances:**
- Top produits par chiffre d'affaires
- Répartition par catégorie
- Pourcentage du CA total par produit

### Dashboard

Le tableau de bord affiche en temps réel:
- 📊 Chiffre d'affaires du jour
- 🍽️ Nombre de ventes
- 💰 Panier moyen
- 📦 Valeur du stock
- ⚠️ Nombre d'alertes actives
- 📈 Évolution des ventes

### Gestion des Recettes

Pour chaque plat:
- Liste des ingrédients
- Quantités nécessaires
- Coût matière détaillé
- Marge bénéficiaire
- Prix de vente conseillé

### Inventaires

Procédure d'inventaire:
1. Imprimez la fiche d'inventaire
2. Comptez les stocks réels
3. Saisissez les quantités trouvées
4. Le système calcule les écarts
5. Analyse des pertes et gaspillages

## 🔒 Sécurité

### Protection des données

- Protection par mot de passe des feuilles sensibles
- Sauvegarde automatique des données
- Journalisation des actions utilisateurs
- Niveaux d'accès configurables

### Sauvegarde

Pour créer une sauvegarde manuelle:
```vba
Call SauvegarderDonnees
```

Les sauvegardes sont stockées dans le dossier `Backups/` avec un timestamp.

## 🛠️ Personnalisation

### Modifier les paramètres

La feuille `Config` permet de modifier:
- Taux de TVA
- Devises
- Formats de date
- Seuils d'alerte

### Ajouter des fonctionnalités

Les modules VBA sont modulaires et extensibles. Consultez la documentation technique pour ajouter:
- De nouveaux rapports
- Des automatisations supplémentaires
- Des intégrations externes

## 📊 Indicateurs Clés de Performance (KPI)

### Financiers
- Chiffre d'affaires quotidien/hebdomadaire/mensuel
- Marge brute par plat
- Coût matière (%)
- Panier moyen

### Opérationnels
- Taux de rotation des stocks
- Taux de rupture
- Taux de gaspillage
- Performance par serveur

### Commerciaux
- Top 10 des plats les plus vendus
- Répartition CA par catégorie
- Évolution du CA jour/semaine/mois

## 🆘 Dépannage

### Problèmes courants

**Les macros ne s'exécutent pas:**
- Vérifiez que le fichier est au format .xlsm
- Activez les macros dans les options Excel
- Redémarrez Excel

**Erreur lors de l'initialisation:**
- Vérifiez que toutes les feuilles existent
- Exécutez `ConfigurerPremiereUtilisation`

**Données manquantes:**
- Restaurez une sauvegarde récente
- Vérifiez les filtres appliqués

### Support technique

Pour toute assistance:
1. Notez le message d'erreur complet
2. Identifiez l'action en cours
3. Contactez votre administrateur système

## 📝 Bonnes pratiques

### Quotidiennement
- ✅ Enregistrer toutes les ventes en temps réel
- ✅ Noter les entrées de stock dès réception
- ✅ Vérifier les alertes de stock
- ✅ Consulter le dashboard

### Hebdomadairement
- 📊 Analyser les performances de la semaine
- 📦 Commander les produits en stock faible
- 💵 Réviser les prix si nécessaire

### Mensuellement
- 📋 Réaliser l'inventaire complet
- 📈 Analyser les tendances
- 🔄 Mettre à jour les fiches recettes
- 💾 Archiver les données du mois

## 📄 Licence

Cette application est fournie "clé en main" pour un usage professionnel. Toute modification doit préserver l'intégrité du système.

---

**Version:** 1.0.0  
**Date de création:** 2024  
**Développé avec:** Microsoft Excel VBA
