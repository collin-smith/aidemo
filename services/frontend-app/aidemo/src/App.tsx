
import {  BrowserRouter,Route, Routes} from 'react-router-dom';
import Home from './pages/Home';
import Navigation from './components/Navigation';

import './App.css'
import './index.css'

import Upload from './pages/Upload';
import Gallery from './pages/Gallery';
import PromptEngineering from './pages/PromptEngineering';
import ImageAnalysis from './pages/ImageAnalysis';
import ImageGeneration from './pages/ImageGeneration';
import DocumentAnalysis from './pages/DocumentAnalysis';
import DocumentAnalysisLlm from './pages/DocumentAnalysisLlm';


function App() {
  return (
    <BrowserRouter>
    <div className="grid md:grid-cols-1">
      <Navigation />
    </div>
    <main className="grid">
      <Routes>
          <Route path="/" element={<Home />} />
          <Route path="gallery" element={<Gallery />} />
          <Route path="upload" element={<Upload />} />
          <Route path="promptengineering" element={<PromptEngineering />} />
          <Route path="imageanalysis" element={<ImageAnalysis />} />
          <Route path="imagegeneration" element={<ImageGeneration />} />
          <Route path="documentanalysis" element={<DocumentAnalysis />} />
          <Route path="documentanalysisllm" element={<DocumentAnalysisLlm />} />
      </Routes>
    </main>
  </BrowserRouter>
  )
}

export default App
