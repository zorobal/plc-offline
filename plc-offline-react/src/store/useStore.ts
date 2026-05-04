import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface Tag {
  id: string;
  name: string;
  type: 'BOOL' | 'INT' | 'REAL' | 'STRING';
  address: string;
  value: any;
}

export interface RungElement {
  type: 'contact_no' | 'contact_nc' | 'coil' | 'timer_on' | 'timer_off' | 'counter_up' | 'counter_down';
  address: string;
  label?: string;
  value?: number;
}

export interface Rung {
  id: number;
  elements: RungElement[];
}

export interface PLCProgram {
  id: string;
  name: string;
  description: string;
  rungs: Rung[];
  tags: Tag[];
  createdAt: number;
  updatedAt: number;
}

interface AppState {
  // Program state
  currentProgram: PLCProgram | null;
  programs: PLCProgram[];
  isRunning: boolean;
  
  // UI state
  activeTab: 'ladder' | 'st' | 'tags' | 'simulation';
  language: 'fr' | 'en';
  sidebarOpen: boolean;
  
  // AI state
  isGenerating: boolean;
  aiMessage: string | null;
  
  // Actions
  setCurrentProgram: (program: PLCProgram | null) => void;
  addProgram: (program: PLCProgram) => void;
  updateProgram: (program: PLCProgram) => void;
  deleteProgram: (id: string) => void;
  setRunning: (running: boolean) => void;
  setActiveTab: (tab: 'ladder' | 'st' | 'tags' | 'simulation') => void;
  setLanguage: (lang: 'fr' | 'en') => void;
  toggleSidebar: () => void;
  setGenerating: (generating: boolean) => void;
  setAiMessage: (message: string | null) => void;
  addTag: (tag: Tag) => void;
  updateTag: (tag: Tag) => void;
  deleteTag: (id: string) => void;
  addRung: (rung: Rung) => void;
  updateRung: (rung: Rung) => void;
  deleteRung: (id: number) => void;
}

const defaultProgram: PLCProgram = {
  id: 'default',
  name: 'New Program',
  description: '',
  rungs: [],
  tags: [],
  createdAt: Date.now(),
  updatedAt: Date.now(),
};

export const useStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial state
      currentProgram: defaultProgram,
      programs: [],
      isRunning: false,
      activeTab: 'ladder',
      language: 'fr',
      sidebarOpen: true,
      isGenerating: false,
      aiMessage: null,

      // Actions
      setCurrentProgram: (program) => set({ currentProgram: program }),
      
      addProgram: (program) => set((state) => ({
        programs: [...state.programs, program],
        currentProgram: program,
      })),
      
      updateProgram: (program) => set((state) => ({
        currentProgram: program,
        programs: state.programs.map(p => p.id === program.id ? program : p),
      })),
      
      deleteProgram: (id) => set((state) => ({
        programs: state.programs.filter(p => p.id !== id),
        currentProgram: state.currentProgram?.id === id ? null : state.currentProgram,
      })),
      
      setRunning: (running) => set({ isRunning: running }),
      
      setActiveTab: (tab) => set({ activeTab: tab }),
      
      setLanguage: (lang) => set({ language: lang }),
      
      toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
      
      setGenerating: (generating) => set({ isGenerating: generating }),
      
      setAiMessage: (message) => set({ aiMessage: message }),
      
      addTag: (tag) => set((state) => ({
        currentProgram: state.currentProgram ? {
          ...state.currentProgram,
          tags: [...state.currentProgram.tags, tag],
          updatedAt: Date.now(),
        } : null,
      })),
      
      updateTag: (tag) => set((state) => ({
        currentProgram: state.currentProgram ? {
          ...state.currentProgram,
          tags: state.currentProgram.tags.map(t => t.id === tag.id ? tag : t),
          updatedAt: Date.now(),
        } : null,
      })),
      
      deleteTag: (id) => set((state) => ({
        currentProgram: state.currentProgram ? {
          ...state.currentProgram,
          tags: state.currentProgram.tags.filter(t => t.id !== id),
          updatedAt: Date.now(),
        } : null,
      })),
      
      addRung: (rung) => set((state) => ({
        currentProgram: state.currentProgram ? {
          ...state.currentProgram,
          rungs: [...state.currentProgram.rungs, rung],
          updatedAt: Date.now(),
        } : null,
      })),
      
      updateRung: (rung) => set((state) => ({
        currentProgram: state.currentProgram ? {
          ...state.currentProgram,
          rungs: state.currentProgram.rungs.map(r => r.id === rung.id ? rung : r),
          updatedAt: Date.now(),
        } : null,
      })),
      
      deleteRung: (id) => set((state) => ({
        currentProgram: state.currentProgram ? {
          ...state.currentProgram,
          rungs: state.currentProgram.rungs.filter(r => r.id !== id),
          updatedAt: Date.now(),
        } : null,
      })),
    }),
    {
      name: 'plc-storage',
      partialize: (state) => ({ 
        programs: state.programs,
        currentProgram: state.currentProgram,
        language: state.language,
      }),
    }
  )
);
