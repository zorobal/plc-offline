# Application Excel de Gestion de Restaurant - Documentation Technique

## 📁 Structure du Projet

### Arborescence des Fichiers

```
RestaurantManagement/
├── VBA_Modules/
│   ├── Module_Principal.bas       # Navigation, initialisation, utilitaires
│   ├── Module_Stocks.bas          # Gestion des stocks et mouvements
│   ├── Module_Ventes.bas          # Enregistrement et suivi des ventes
│   ├── Module_Recettes.bas        # Fiches techniques et coûts matières
│   ├── Module_Fournisseurs.bas    # Gestion fournisseurs et commandes
│   └── Module_Rapports.bas        # Génération de rapports (à créer)
├── Data_Files/
│   ├── Données_Produits.xlsx      # Base de données produits
│   ├── Données_Ventes.xlsx        # Historique des ventes
│   ├── Données_Fournisseurs.xlsx  # Base de données fournisseurs
│   └── Données_Recettes.xlsx      # Fiches recettes
├── Documentation/
│   ├── GUIDE_UTILISATION.md       # Guide utilisateur
│   └── DOCUMENTATION_TECHNIQUE.md # Ce fichier
├── Templates/
│   └── GestionRestaurant_Template.xlsm
└── Reports/
    └── (Rapports PDF générés)
```

## 🏗️ Architecture Technique

### Feuilles Excel Requises

| Nom de la feuille | Description | Colonnes principales |
|-------------------|-------------|---------------------|
| **Accueil** | Page de navigation | Interface graphique avec boutons |
| **Dashboard** | Tableau de bord | Indicateurs KPI |
| **Config** | Configuration | Paramètres globaux |
| **Stocks** | Produits et matières | ID, Réf, Nom, Catégorie, UM, Prix Achat, Prix Vente, Stock, Stock Min, Stock Sécurité, Date MAJ |
| **Mouvements_Stock** | Historique stock | ID, Date, ID Produit, Nom, Type, Quantité, P.U., Total, Document, Utilisateur |
| **Ventes** | Ventes journalières | ID, Date, Date Formatée, Heure, Plat, Catégorie, Qté, P.U., Total HT, TVA, Total TTC, Paiement, Serveur, Statut |
| **Recettes** | Fiches techniques | ID, Nom, Catégorie, Portions, Temps, Prix TTC, Coût Matière, Marge %, Date Création, Date MAJ |
| **Ingredients_Recettes** | Ingrédients par recette | ID, ID Recette, ID Produit, Nom, Quantité, UM, Prix Achat, Coût, Date |
| **Fournisseurs** | Base fournisseurs | ID, Nom, Contact, Téléphone, Email, Adresse, Catégorie, Statut, Date, Commandes, Total Acheté |
| **Achats** | Commandes fournisseurs | ID, Date, ID Fournisseur, Nom, N° Cmd, Produit, Qté, UM, P.U., Total HT, TVA, Total TTC, Livraison, Statut, Utilisateur, Date Réception |
| **Alertes_Stock** | Alertes générées | ID, Réf, Produit, Stock Actuel, Stock Min, Stock Sécurité, Type Alerte, Date |

### Modules VBA

#### Module_Principal.bas

**Variables Globales:**
```vba
Public gUserName As String      ' Utilisateur connecté
Public gLoginTime As Date       ' Heure de connexion
Public gLastBackup As Date      ' Dernière sauvegarde
```

**Procédures Principales:**
- `InitialiserApplication()` - Initialisation au démarrage
- `AfficherPageAccueil()` - Navigation vers l'accueil
- `NaviguerVersModule(moduleName)` - Navigation modulaire
- `VerifierAlertes()` - Vérification des alertes
- `SauvegarderDonnees()` - Sauvegarde automatique
- `ActualiserTableauxCroises()` - Refresh des TCD
- `ExporterRapport(sheetName)` - Export PDF

#### Module_Stocks.bas

**Fonctions Clés:**
- `AjouterProduit()` - CRUD produit
- `ModifierProduit()` - Modification produit
- `EnregistrerEntreeStock()` - Entrée de stock
- `EnregistrerSortieStock()` - Sortie de stock
- `GenererAlertesStock()` - Rapport d'alertes
- `CalculerValeurStock() As Double` - Valeur totale du stock

**Règles de Gestion:**
- Stock minimum déclenche une alerte jaune
- Stock de sécurité déclenche une alerte orange
- Stock nul déclenche une alerte rouge
- FIFO implicite dans la gestion

#### Module_Ventes.bas

**Fonctions Clés:**
- `EnregistrerVente()` - Saisie vente
- `GenererRapportJournalier()` - Rapport jour
- `AnalyserPerformances()` - Top produits
- `MettreAJourDashboard()` - Update temps réel

**Calculs Automatiques:**
- TVA restaurant: 10%
- Total HT = Quantité × Prix Unitaire
- Total TTC = Total HT × 1.10

#### Module_Recettes.bas

**Fonctions Clés:**
- `CreerRecette()` - Nouvelle fiche
- `AjouterIngredientRecette()` - Ajout ingrédient
- `CalculerCoutIngredient()` - Conversion unités
- `CalculerCoutRecette(idRecette)` - Coût total
- `AnalyserMarges()` - Analyse rentabilité
- `ImprimerFicheTechnique()` - Fiche imprimable

**Gestion des Unités:**
```vba
' Facteurs de conversion
kg → g: /1000
L → ml: /1000
unité → unité: ×1
```

**Seuils de Marge:**
- ≥ 70%: Excellent (vert)
- ≥ 60%: Bon (vert clair)
- ≥ 50%: Correct (jaune)
- < 50%: À revoir (rouge)

#### Module_Fournisseurs.bas

**Fonctions Clés:**
- `AjouterFournisseur()` - CRUD fournisseur
- `PasserCommande()` - Nouvelle commande
- `ReceptionnerCommande()` - Validation livraison
- `AnalyserAchats()` - Stats par fournisseur
- `GenererEtatCommandes()` - Suivi commandes

**Statuts de Commande:**
- EN ATTENTE
- LIVREE
- ANNULEE

## 🔧 Installation et Configuration

### Étapes d'Installation Détaillées

1. **Préparation de l'environnement Excel**
```
Fichier > Options > Centre de gestion de la confidentialité
  > Paramètres des macros > Activer toutes les macros
  > Paramètres des contrôles ActiveX > Activer tous les contrôles
```

2. **Import des modules VBA**
```
ALT + F11 pour ouvrir l'éditeur VBA
Fichier > Importer un fichier
Sélectionner chaque fichier .bas dans VBA_Modules/
```

3. **Création des feuilles**
- Créer chaque feuille listée ci-dessus
- Nommer exactement comme indiqué (case sensitive)
- Appliquer les formats de colonnes spécifiés

4. **Configuration initiale**
Dans la feuille `Config`:
```
B1: Date de création (=NOW())
B2: Version (1.0.0)
B3: Dernière sauvegarde
```

### Code d'Initialisation AutoRun

Dans `ThisWorkbook`:
```vba
Private Sub Workbook_Open()
    Call InitialiserApplication
End Sub
```

## 📊 Formules Excel Recommandées

### Feuille Stocks

| Colonne | Formule | Description |
|---------|---------|-------------|
| H (Stock) | `=SUMIF(Mouvements!C:C,A2,Mouvements!F:F)-SUMIF(Mouvements!C:C,A2,Mouvements!G:G)` | Calcul dynamique |
| L (Valeur) | `=H2*F2` | Valorisation |

### Feuille Dashboard

| Cellule | Formule | Description |
|---------|---------|-------------|
| B3 (CA Jour) | `=SUMIFS(Ventes!K:K,Ventes!C:C,TODAY())` | CA du jour |
| B4 (Nbre Ventes) | `=COUNTIFS(Ventes!C:C,TODAY())` | Nombre |
| B5 (Panier Moyen) | `=B3/B4` | Moyenne |

## 🔒 Sécurité

### Protection des Feuilles

```vba
Sub ProtegerFeuilles()
    Dim ws As Worksheet
    Dim motDePasse As String
    motDePasse = "VotreMotDePasse"
    
    For Each ws In ThisWorkbook.Worksheets
        If ws.Name <> "Accueil" And ws.Name <> "Dashboard" Then
            ws.Protect Password:=motDePasse, _
                      UserInterfaceOnly:=True, _
                      AllowFormattingCells:=True
        End If
    Next ws
End Sub
```

### Niveau d'Accès

| Profil | Accès |
|--------|-------|
| Administrateur | Tous les modules |
| Manager | Ventes, Stocks, Rapports |
| Serveur | Ventes uniquement |
| Cuisine | Stocks, Recettes |

## 📈 Tableaux Croisés Dynamiques Recommandés

### Dashboard Principal

1. **CA par Mois**
   - Source: Ventes
   - Lignes: Mois
   - Valeurs: Sum of Total TTC

2. **Top 10 Produits**
   - Source: Ventes
   - Lignes: Plat
   - Valeurs: Sum of Total HT
   - Filtre: Top 10

3. **Évolution des Stocks**
   - Source: Mouvements_Stock
   - Lignes: Produit, Date
   - Valeurs: Sum of Quantité

### Rapports Analytiques

4. **Marges par Catégorie**
   - Source: Recettes
   - Lignes: Catégorie
   - Valeurs: Average of Marge %

5. **Achats par Fournisseur**
   - Source: Achats
   - Lignes: Fournisseur
   - Valeurs: Sum of Total TTC

## 🔄 Workflows Métier

### Workflow: Réception Marchandise

```
1. Réception physique → 2. Vérifier bon de livraison → 3. Dans Excel:
   → Module_Fournisseurs.ReceptionnerCommande()
   → Saisir ID commande
   → Confirmer quantités
   → Mettre à jour stock (Oui/Non)
   → 4. Archivage du BL papier
```

### Workflow: Inventaire Mensuel

```
1. Générer fiche inventaire → 2. Comptage physique → 
3. Saisir quantités réelles → 4. Calcul des écarts → 
5. Analyse des pertes → 6. Ajustement des stocks → 
7. Rapport de direction
```

### Workflow: Création Nouveau Plat

```
1. Module_Recettes.CreerRecette() → 
2. Définir prix de vente → 
3. Module_Recettes.AjouterIngredientRecette() 
   (pour chaque ingrédient) → 
4. Module_Recettes.CalculerCoutRecette() → 
5. Vérifier marge (>60%) → 
6. Si OK: ajouter à la carte → 
7. Former le personnel
```

## 🐛 Débogage

### Journalisation

Ajouter dans chaque module:
```vba
Private Sub LogAction(action As String, details As String)
    Dim wsLog As Worksheet
    Set wsLog = ThisWorkbook.Sheets("Log_Activites")
    
    Dim nextRow As Long
    nextRow = wsLog.Cells(wsLog.Rows.Count, "A").End(xlUp).Row + 1
    
    wsLog.Cells(nextRow, 1).Value = Now
    wsLog.Cells(nextRow, 2).Value = gUserName
    wsLog.Cells(nextRow, 3).Value = action
    wsLog.Cells(nextRow, 4).Value = details
End Sub
```

### Gestion des Erreurs Standardisée

```vba
On Error GoTo ErrorHandler

' ... code ...

Exit Sub

ErrorHandler:
    LogAction "ERREUR", Err.Description
    MsgBox "Erreur: " & Err.Description & vbCrLf & _
           "Procédure: " & Erl, vbCritical
    Resume Next
```

## 📞 Support et Maintenance

### Checklist Maintenance Hebdomadaire

- [ ] Vérifier les sauvegardes
- [ ] Contrôler les alertes de stock
- [ ] Analyser les écarts d'inventaire
- [ ] Mettre à jour les prix fournisseurs
- [ ] Nettoyer les données obsolètes

### Procédure de Restauration

1. Identifier la dernière sauvegarde valide
2. Fermer Excel complètement
3. Copier le fichier de sauvegarde
4. Renommer en `GestionRestaurant.xlsm`
5. Rouvrir et vérifier les données

---

**Version:** 1.0.0  
**Dernière mise à jour:** 2024  
**Contact support:** support@restaurant-app.com
