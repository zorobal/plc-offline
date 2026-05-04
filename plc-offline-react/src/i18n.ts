import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

const resources = {
  fr: {
    translation: {
      // Navigation
      'nav.home': 'Accueil',
      'nav.editor': 'Éditeur',
      'nav.examples': 'Exemples',
      'nav.challenges': 'Défis',
      'nav.community': 'Communauté',
      
      // Hero
      'hero.title': 'Simulateur PLC en Ligne',
      'hero.subtitle': 'Apprenez la programmation automate avec notre simulateur interactif',
      'hero.cta': 'Commencer maintenant',
      
      // Editor
      'editor.ladder': 'Ladder',
      'editor.st': 'Structured Text',
      'editor.tags': 'Tags',
      'editor.simulation': 'Simulation',
      'editor.run': 'Démarrer',
      'editor.stop': 'Arrêter',
      'editor.reset': 'Réinitialiser',
      'editor.save': 'Sauvegarder',
      'editor.load': 'Charger',
      'editor.export': 'Exporter',
      'editor.import': 'Importer',
      
      // AI Features
      'ai.generate': '🤖 Générer avec IA',
      'ai.explain': '💡 Expliquer',
      'ai.debug': '🔍 Debugger',
      'ai.prompt': 'Décrivez votre programme...',
      'ai.generating': 'Génération en cours...',
      'ai.error': 'Erreur de génération',
      
      // Tags
      'tags.add': 'Ajouter un tag',
      'tags.name': 'Nom',
      'tags.type': 'Type',
      'tags.address': 'Adresse',
      'tags.value': 'Valeur',
      'tags.delete': 'Supprimer',
      
      // Messages
      'msg.saved': 'Projet sauvegardé',
      'msg.loaded': 'Projet chargé',
      'msg.running': 'Simulation en cours',
      'msg.stopped': 'Simulation arrêtée',
      'msg.error': 'Une erreur est survenue',
    }
  },
  en: {
    translation: {
      // Navigation
      'nav.home': 'Home',
      'nav.editor': 'Editor',
      'nav.examples': 'Examples',
      'nav.challenges': 'Challenges',
      'nav.community': 'Community',
      
      // Hero
      'hero.title': 'Online PLC Simulator',
      'hero.subtitle': 'Learn PLC programming with our interactive simulator',
      'hero.cta': 'Get Started',
      
      // Editor
      'editor.ladder': 'Ladder',
      'editor.st': 'Structured Text',
      'editor.tags': 'Tags',
      'editor.simulation': 'Simulation',
      'editor.run': 'Run',
      'editor.stop': 'Stop',
      'editor.reset': 'Reset',
      'editor.save': 'Save',
      'editor.load': 'Load',
      'editor.export': 'Export',
      'editor.import': 'Import',
      
      // AI Features
      'ai.generate': '🤖 Generate with AI',
      'ai.explain': '💡 Explain',
      'ai.debug': '🔍 Debug',
      'ai.prompt': 'Describe your program...',
      'ai.generating': 'Generating...',
      'ai.error': 'Generation error',
      
      // Tags
      'tags.add': 'Add Tag',
      'tags.name': 'Name',
      'tags.type': 'Type',
      'tags.address': 'Address',
      'tags.value': 'Value',
      'tags.delete': 'Delete',
      
      // Messages
      'msg.saved': 'Project saved',
      'msg.loaded': 'Project loaded',
      'msg.running': 'Simulation running',
      'msg.stopped': 'Simulation stopped',
      'msg.error': 'An error occurred',
    }
  }
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'fr',
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
    },
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
