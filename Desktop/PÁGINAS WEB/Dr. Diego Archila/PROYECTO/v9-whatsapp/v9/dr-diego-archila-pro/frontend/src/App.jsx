import React, { useState, useEffect } from 'react'
import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom'
import Header from './components/Header'
import Footer from './components/Footer'
import Loader from './components/Loader'
import WhatsAppFloat from './components/WhatsAppFloat'
import Home from './pages/Home'
import Servicios from './pages/Servicios'
import CasosClinicos from './pages/CasosClinicos'
import Conocenos from './pages/Conocenos'
import Contacto from './pages/Contacto'
import Agendar from './pages/Agendar'
import NotFound from './pages/NotFound'
import './App.css'

function ScrollTop() {
  const { pathname } = useLocation()
  useEffect(() => { window.scrollTo(0, 0) }, [pathname])
  return null
}

function PageWrapper({ children }) {
  return <div className="page-enter">{children}</div>
}

function AppContent() {
  return (
    <>
      <ScrollTop />
      <Header />
      <main>
        <Routes>
          <Route path="/" element={<PageWrapper><Home /></PageWrapper>} />
          <Route path="/servicios" element={<PageWrapper><Servicios /></PageWrapper>} />
          <Route path="/casos" element={<PageWrapper><CasosClinicos /></PageWrapper>} />
          <Route path="/conocenos" element={<PageWrapper><Conocenos /></PageWrapper>} />
          <Route path="/contacto" element={<PageWrapper><Contacto /></PageWrapper>} />
          <Route path="/agendar" element={<PageWrapper><Agendar /></PageWrapper>} />
          <Route path="*" element={<PageWrapper><NotFound /></PageWrapper>} />
        </Routes>
      </main>
      <Footer />
      <WhatsAppFloat />
    </>
  )
}

export default function App() {
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const t = setTimeout(() => setLoading(false), 2200)
    return () => clearTimeout(t)
  }, [])

  return (
    <BrowserRouter>
      {loading && <Loader />}
      {!loading && <AppContent />}
    </BrowserRouter>
  )
}
