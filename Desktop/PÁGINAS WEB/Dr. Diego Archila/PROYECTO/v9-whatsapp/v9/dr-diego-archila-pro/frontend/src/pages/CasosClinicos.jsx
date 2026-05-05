import React, { useState, useRef, useEffect, useCallback } from 'react'
import { useScrollAnimationAll } from '../hooks/useScrollAnimation'
import caso1a from '../assets/casos/caso1_antes.png'
import caso1d from '../assets/casos/caso1_despues.png'
import caso2a from '../assets/casos/caso2_antes.png'
import caso2d from '../assets/casos/caso2_despues.png'
import caso3a from '../assets/casos/caso3_antes.png'
import caso3d from '../assets/casos/caso3_despues.png'
import caso4a from '../assets/casos/caso4_antes.png'
import caso4d from '../assets/casos/caso4_despues.png'
import caso5a from '../assets/casos/caso5_antes.png'
import caso5d from '../assets/casos/caso5_despues.png'
import caso6a from '../assets/casos/caso6_antes.png'
import caso6d from '../assets/casos/caso6_despues.png'
import gallery1 from '../assets/casos/gallery1.jpg'
import gallery2 from '../assets/casos/gallery2.jpg'
import gallery3 from '../assets/casos/gallery3.jpg'
import gallery4 from '../assets/casos/gallery4.jpg'
import gallery5 from '../assets/casos/gallery5.jpg'
import gallery6 from '../assets/casos/gallery6.jpg'
import videoExp from '../assets/videos/exp1.mp4'
import './CasosClinicos.css'

const TODO = 'Todos'
const casosPares = [
  { titulo: 'Diseño de Sonrisa Integral', categoria: 'Diseño de Sonrisa', antes: caso1a, despues: caso1d },
  { titulo: 'Carillas en Resina Estratificada', categoria: 'Carillas', antes: caso2a, despues: caso2d },
  { titulo: 'Estética Dental Directa', categoria: 'Estética Dental', antes: caso3a, despues: caso3d, beforePos: 'center 35%' },
  { titulo: 'Diseño de Sonrisa Completo', categoria: 'Diseño de Sonrisa', antes: caso4a, despues: caso4d },
  { titulo: 'Composite y Blanqueamiento', categoria: 'Estética Dental', antes: caso5a, despues: caso5d, beforePos: 'center 42%', afterPos: 'center 42%' },
  { titulo: 'Carillas y Diseño Personalizado', categoria: 'Carillas', antes: caso6a, despues: caso6d },
]
const categorias = [TODO, 'Diseño de Sonrisa', 'Carillas', 'Estética Dental']
const gallery = [gallery1, gallery2, gallery3, gallery4, gallery5, gallery6]

function BeforeAfterSlider({ before, after, titulo, categoria, beforePos, afterPos }) {
  const [pos, setPos] = useState(50)
  const [dragging, setDragging] = useState(false)
  const containerRef = useRef(null)

  const getPos = useCallback((clientX) => {
    if (!containerRef.current) return
    const rect = containerRef.current.getBoundingClientRect()
    setPos(Math.min(Math.max(((clientX - rect.left) / rect.width) * 100, 2), 98))
  }, [])

  useEffect(() => {
    const up = () => setDragging(false)
    window.addEventListener('mouseup', up)
    window.addEventListener('touchend', up)
    return () => { window.removeEventListener('mouseup', up); window.removeEventListener('touchend', up) }
  }, [])

  return (
    <div className="ba-card glass-card">
      <div
        className={`ba-slider${dragging ? ' is-dragging' : ''}`}
        ref={containerRef}
        onMouseDown={e => { setDragging(true); getPos(e.clientX) }}
        onMouseMove={e => { if (dragging) getPos(e.clientX) }}
        onTouchStart={e => { setDragging(true); getPos(e.touches[0].clientX) }}
        onTouchMove={e => { if (dragging) getPos(e.touches[0].clientX) }}
        onTouchEnd={() => setDragging(false)}
      >
        <img src={after} alt="Después" className="ba-img" draggable={false} style={afterPos ? { objectPosition: afterPos } : undefined} />
        <div className="ba-before" style={{ clipPath: `inset(0 ${100 - pos}% 0 0)` }}>
          <img src={before} alt="Antes" className="ba-img" draggable={false} style={beforePos ? { objectPosition: beforePos } : undefined} />
        </div>
        <div className="ba-handle" style={{ left: `${pos}%` }}>
          <div className="ba-handle__line" />
          <div className="ba-handle__circle">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
              <path d="M9 18l-6-6 6-6M15 6l6 6-6 6"/>
            </svg>
          </div>
          <div className="ba-handle__line" />
        </div>
        <span className="ba-tag ba-tag--before">ANTES</span>
        <span className="ba-tag ba-tag--after">DESPUÉS</span>
      </div>
      <div className="ba-card__foot">
        <span className="ba-card__cat">{categoria}</span>
        <h3 className="ba-card__title">{titulo}</h3>
      </div>
    </div>
  )
}

export default function CasosClinicos() {
  useScrollAnimationAll()
  const [filtro, setFiltro] = useState(TODO)
  const [lightbox, setLightbox] = useState(null)
  const videoRef = useRef(null)

  useEffect(() => {
    if (videoRef.current) videoRef.current.play().catch(() => {})
  }, [])

  const casosFiltrados = filtro === TODO ? casosPares : casosPares.filter(c => c.categoria === filtro)

  return (
    <div className="casos-page">
      <section className="page-hero">
        <div className="container">
          <div className="page-hero__content animate-fade-up">
            <span className="section-label">Transformaciones reales</span>
            <div className="gold-line" />
            <h1 className="page-hero__title">Casos <em>clínicos</em></h1>
            <p className="page-hero__sub">Resultados reales de pacientes reales. Arrastra el divisor para revelar cada transformación.</p>
          </div>
        </div>
      </section>

      {/* VIDEO */}
      <section className="section casos-video-section">
        <div className="container">
          <div className="casos-video-wrap animate-fade-up">
            <div className="casos-video-text">
              <span className="section-label">Historia de transformación</span>
              <div className="gold-line" />
              <h2 className="section-heading">Detrás de cada caso<br /><em>hay una historia</em></h2>
              <p style={{ color: 'var(--white-60)', lineHeight: '1.85', fontSize: '0.9rem', marginTop: '1rem' }}>
                La odontología estética es más que cambiar sonrisas. Es devolver confianza, transformar vidas y acompañar a cada persona en su proceso de amor propio.
              </p>
            </div>
            <div className="casos-video-player">
              {/* muted al iniciar — el usuario activa el sonido manualmente. */}
              <video ref={videoRef} autoPlay loop muted playsInline controls preload="metadata">
                <source src={videoExp} type="video/mp4" />
              </video>
            </div>
          </div>
        </div>
      </section>

      {/* BEFORE/AFTER */}
      <section className="section casos-ba-section">
        <div className="container">
          <div className="section__header animate-fade-up">
            <span className="section-label">Antes y después</span>
            <div className="gold-line" />
            <h2 className="section-heading">Comparador <em>interactivo</em></h2>
          </div>
          <div className="casos-filter animate-fade-up">
            {categorias.map(c => (
              <button
                key={c}
                className={`filter-btn${filtro === c ? ' active' : ''}`}
                onClick={() => setFiltro(c)}
              >{c}</button>
            ))}
          </div>
          <div className="ba-grid animate-fade-up">
            {casosFiltrados.map((c, i) => (
              <BeforeAfterSlider key={i} before={c.antes} after={c.despues} titulo={c.titulo} categoria={c.categoria} beforePos={c.beforePos} afterPos={c.afterPos} />
            ))}
          </div>
        </div>
      </section>

      {/* GALLERY */}
      <section className="section casos-gallery-section">
        <div className="container">
          <div className="section__header animate-fade-up">
            <span className="section-label">Galería</span>
            <div className="gold-line" />
            <h2 className="section-heading">Diseños de <em>sonrisa</em></h2>
          </div>
          <div className="gallery-grid animate-fade-up">
            {gallery.map((img, i) => (
              <button key={i} className="gallery-item" onClick={() => setLightbox(img)}>
                <img src={img} alt={`Caso ${i + 1}`} />
                <div className="gallery-item__overlay">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M15 3h6m0 0v6m0-6l-7 7M9 21H3m0 0v-6m0 6l7-7"/></svg>
                </div>
              </button>
            ))}
          </div>
        </div>
      </section>

      {lightbox && (
        <div className="casos-lightbox" onClick={() => setLightbox(null)}>
          <button className="casos-lightbox__close" onClick={() => setLightbox(null)}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
          <img src={lightbox} alt="Caso clínico" onClick={e => e.stopPropagation()} />
        </div>
      )}
    </div>
  )
}
