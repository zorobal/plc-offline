import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Play, Square, RotateCcw, Save, FolderOpen, Download, Upload, Menu, X, Globe, Cpu, Code, Tag, Activity } from 'lucide-react'
import { useStore } from './store/useStore'
import { mistralClient } from './services/mistral'
import MonacoEditor from '@monaco-editor/react'

function App() {
  const { t, i18n } = useTranslation()
  const [showAiModal, setShowAiModal] = useState(false)
  const [aiPrompt, setAiPrompt] = useState('')
  const [stCode, setStCode] = useState('// Structured Text code here\nPROGRAM Main\nVAR\n    Start : BOOL;\n    Motor : BOOL;\nEND_VAR\n\nIF Start THEN\n    Motor := TRUE;\nELSE\n    Motor := FALSE;\nEND_IF;\nEND_PROGRAM')
  
  const { 
    currentProgram, 
    isRunning, 
    activeTab, 
    sidebarOpen,
    language,
    isGenerating,
    aiMessage,
    setRunning, 
    setActiveTab, 
    toggleSidebar,
    setLanguage,
    setGenerating,
    setAiMessage,
    setCurrentProgram
  } = useStore()

  const handleGenerateAI = async () => {
    if (!aiPrompt.trim()) return
    
    setGenerating(true)
    setAiMessage(null)
    
    try {
      const result = await mistralClient.generateLadder(aiPrompt)
      const programData = JSON.parse(result)
      
      const newProgram = {
        id: Date.now().toString(),
        name: 'AI Generated Program',
        description: aiPrompt,
        rungs: programData.rungs || [],
        tags: [],
        createdAt: Date.now(),
        updatedAt: Date.now(),
      }
      
      setCurrentProgram(newProgram)
      setShowAiModal(false)
      setAiMessage(t('msg.saved'))
    } catch (error) {
      setAiMessage(t('ai.error'))
    } finally {
      setGenerating(false)
    }
  }

  const toggleLanguage = () => {
    const newLang = language === 'fr' ? 'en' : 'fr'
    setLanguage(newLang)
    i18n.changeLanguage(newLang)
  }

  return (
    <div className="min-h-screen bg-dark text-light flex flex-col">
      {/* Header */}
      <header className="bg-primary border-b border-secondary px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <button onClick={toggleSidebar} className="p-2 hover:bg-white/10 rounded">
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
          <div className="flex items-center gap-2">
            <Cpu size={24} />
            <h1 className="text-xl font-bold">PLC Offline</h1>
          </div>
        </div>
        
        <div className="flex items-center gap-2">
          <button onClick={toggleLanguage} className="flex items-center gap-2 px-3 py-2 hover:bg-white/10 rounded">
            <Globe size={16} />
            <span>{language.toUpperCase()}</span>
          </button>
          
          <button 
            onClick={() => setShowAiModal(true)}
            className="bg-accent hover:bg-blue-600 px-4 py-2 rounded flex items-center gap-2"
          >
            🤖 {t('ai.generate')}
          </button>
        </div>
      </header>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar */}
        {sidebarOpen && (
          <aside className="w-64 bg-secondary border-r border-gray-700 p-4 flex flex-col">
            <nav className="space-y-2">
              <button 
                onClick={() => setActiveTab('ladder')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded ${activeTab === 'ladder' ? 'bg-primary' : 'hover:bg-white/10'}`}
              >
                <Activity size={18} />
                {t('editor.ladder')}
              </button>
              <button 
                onClick={() => setActiveTab('st')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded ${activeTab === 'st' ? 'bg-primary' : 'hover:bg-white/10'}`}
              >
                <Code size={18} />
                {t('editor.st')}
              </button>
              <button 
                onClick={() => setActiveTab('tags')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded ${activeTab === 'tags' ? 'bg-primary' : 'hover:bg-white/10'}`}
              >
                <Tag size={18} />
                {t('editor.tags')}
              </button>
              <button 
                onClick={() => setActiveTab('simulation')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded ${activeTab === 'simulation' ? 'bg-primary' : 'hover:bg-white/10'}`}
              >
                <Cpu size={18} />
                {t('editor.simulation')}
              </button>
            </nav>
            
            <div className="mt-auto pt-4 border-t border-gray-700">
              <div className="text-sm text-gray-400">
                {currentProgram?.name || 'No program loaded'}
              </div>
            </div>
          </aside>
        )}

        {/* Main Content */}
        <main className="flex-1 flex flex-col overflow-hidden">
          {/* Toolbar */}
          <div className="bg-secondary border-b border-gray-700 px-4 py-2 flex items-center gap-2">
            <button 
              onClick={() => setRunning(!isRunning)}
              className={`p-2 rounded flex items-center gap-2 ${isRunning ? 'bg-red-600 hover:bg-red-700' : 'bg-green-600 hover:bg-green-700'}`}
            >
              {isRunning ? <Square size={16} /> : <Play size={16} />}
              {isRunning ? t('editor.stop') : t('editor.run')}
            </button>
            
            <button className="p-2 hover:bg-white/10 rounded" title={t('editor.reset')}>
              <RotateCcw size={16} />
            </button>
            
            <div className="w-px h-6 bg-gray-600 mx-2"></div>
            
            <button className="p-2 hover:bg-white/10 rounded" title={t('editor.save')}>
              <Save size={16} />
            </button>
            <button className="p-2 hover:bg-white/10 rounded" title={t('editor.load')}>
              <FolderOpen size={16} />
            </button>
            <button className="p-2 hover:bg-white/10 rounded" title={t('editor.export')}>
              <Download size={16} />
            </button>
            <button className="p-2 hover:bg-white/10 rounded" title={t('editor.import')}>
              <Upload size={16} />
            </button>
            
            {aiMessage && (
              <span className="ml-auto text-sm text-accent">{aiMessage}</span>
            )}
          </div>

          {/* Editor Area */}
          <div className="flex-1 overflow-auto p-4">
            {activeTab === 'st' && (
              <MonacoEditor
                height="calc(100vh - 200px)"
                language="plaintext"
                value={stCode}
                onChange={(value) => setStCode(value || '')}
                theme="vs-dark"
                options={{
                  minimap: { enabled: false },
                  fontSize: 14,
                  automaticLayout: true,
                }}
              />
            )}
            
            {activeTab === 'ladder' && (
              <div className="h-full flex items-center justify-center border-2 border-dashed border-gray-600 rounded-lg p-8">
                <div className="text-center text-gray-400">
                  <Activity size={48} className="mx-auto mb-4" />
                  <p>Ladder Editor</p>
                  <p className="text-sm mt-2">Use AI to generate a program or add rungs manually</p>
                </div>
              </div>
            )}
            
            {activeTab === 'tags' && (
              <div className="h-full flex items-center justify-center border-2 border-dashed border-gray-600 rounded-lg p-8">
                <div className="text-center text-gray-400">
                  <Tag size={48} className="mx-auto mb-4" />
                  <p>Tags Manager</p>
                  <p className="text-sm mt-2">Add and manage your PLC tags here</p>
                </div>
              </div>
            )}
            
            {activeTab === 'simulation' && (
              <div className="h-full flex items-center justify-center border-2 border-dashed border-gray-600 rounded-lg p-8">
                <div className="text-center text-gray-400">
                  <Cpu size={48} className="mx-auto mb-4" />
                  <p>Simulation View</p>
                  <p className="text-sm mt-2">Run your program to see the simulation</p>
                </div>
              </div>
            )}
          </div>
        </main>
      </div>

      {/* AI Modal */}
      {showAiModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-secondary rounded-lg p-6 w-full max-w-2xl mx-4">
            <h2 className="text-xl font-bold mb-4">{t('ai.generate')}</h2>
            <textarea
              value={aiPrompt}
              onChange={(e) => setAiPrompt(e.target.value)}
              placeholder={t('ai.prompt')}
              className="w-full h-40 bg-dark border border-gray-600 rounded p-3 text-light resize-none focus:outline-none focus:border-primary"
            />
            <div className="flex justify-end gap-2 mt-4">
              <button
                onClick={() => setShowAiModal(false)}
                className="px-4 py-2 hover:bg-white/10 rounded"
              >
                Cancel
              </button>
              <button
                onClick={handleGenerateAI}
                disabled={isGenerating || !aiPrompt.trim()}
                className="px-4 py-2 bg-primary hover:bg-blue-600 rounded disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                {isGenerating ? (
                  <>
                    <span className="animate-spin">⏳</span>
                    {t('ai.generating')}
                  </>
                ) : (
                  t('ai.generate')
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default App
