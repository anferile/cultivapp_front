import React, { useEffect, useRef, useState, useCallback } from 'react'
import { Link } from 'react-router-dom'
import { useScrollAnimationAll } from '../hooks/useScrollAnimation'
import { site, fullAddress } from '../config/site'
import portadaImg from '../assets/hero/portada.png'   // ← reemplaza este archivo por "portada pagina diego Archila.png"
import caso1a from '../assets/casos/caso1_antes.png'
import caso1d from '../assets/casos/caso1_despues.png'
import caso2a from '../assets/casos/caso2_antes.png'
import caso2d from '../assets/casos/caso2_despues.png'
import caso3a from '../assets/casos/caso3_antes.png'
import caso3d from '../assets/casos/caso3_despues.png'
import caso4d from '../assets/casos/caso4_despues.png'
import doctorPerfil from '../assets/doctor/perfil.png'
import './Home.css'

const servicios = [
  { title: 'Diseño de Sonrisa',  desc: 'Transformación estética integral que armoniza tu sonrisa con tus rasgos únicos.', img: caso1d },
  { title: 'Carillas en Resina', desc: 'Lentes de resina estratificada, naturales y mínimamente invasivas.',                img: caso2d },
  { title: 'Blanqueamiento',     desc: 'Blanqueamiento profesional con resultados visibles desde la primera sesión.',     img: caso3d },
  { title: 'Composite Dental',   desc: 'Restauraciones estéticas directas de alta calidad y acabado natural.',            img: caso4d },
]

const casosPreview = [
  { antes: caso1a, despues: caso1d, titulo: 'Diseño de Sonrisa' },
  { antes: caso2a, despues: caso2d, titulo: 'Carillas en Resina' },
  { antes: caso3a, despues: caso3d, titulo: 'Estética Dental' },
]

function MiniBeforeAfter({ antes, despues, titulo }) {
  const [pos, setPos] = useState(50)
  const [dragging, setDragging] = useState(false)
  const ref = useRef(null)

  const calcPos = useCallback((clientX) => {
    if (!ref.current) return
    const rect = ref.current.getBoundingClientRect()
    setPos(Math.min(Math.max(((clientX - rect.left) / rect.width) * 100, 2), 98))
  }, [])

  useEffect(() => {
    const up = () => setDragging(false)
    window.addEventListener('mouseup', up)
    window.addEventListener('touchend', up)
    return () => { window.removeEventListener('mouseup', up); window.removeEventListener('touchend', up) }
  }, [])

  return (
    <div className="mini-ba">
      <div
        className="mini-ba__slider"
        ref={ref}
        onMouseDown={e => { setDragging(true); calcPos(e.clientX) }}
        onMouseMove={e => { if (dragging) calcPos(e.clientX) }}
        onTouchStart={e => { setDragging(true); calcPos(e.touches[0].clientX) }}
        onTouchMove={e => { if (dragging) calcPos(e.touches[0].clientX) }}
      >
        <img src={despues} alt="Después" className="mini-ba__img" draggable={false} />
        <div className="mini-ba__before" style={{ clipPath: `inset(0 ${100 - pos}% 0 0)` }}>
          <img src={antes} alt="Antes" className="mini-ba__img" draggable={false} />
        </div>
        <div className="mini-ba__handle" style={{ left: `${pos}%` }}>
          <div className="mini-ba__line" />
          <div className="mini-ba__btn">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M9 18l-6-6 6-6M15 6l6 6-6 6"/></svg>
          </div>
          <div className="mini-ba__line" />
        </div>
        <span className="mini-ba__tag mini-ba__tag--l">ANTES</span>
        <span className="mini-ba__tag mini-ba__tag--r">DESPUÉS</span>
      </div>
      <p className="mini-ba__title">{titulo}</p>
    </div>
  )
}

export default function Home() {
  useScrollAnimationAll()

  return (
    <div className="home">

      {/* HERO con imagen de portada (reemplaza el video previo) */}
      <section className="hero hero--image">
        <div className="hero__image-wrap">
          <img
            src={portadaImg}
            alt="Dr. Diego Archila — Odontología Estética"
            className="hero__image"
            loading="eager"
            fetchpriority="high"
          />
          <div className="hero__overlay" />
          <div className="hero__gradient-bottom" />
        </div>
        <div className="hero__content container">
          <div className="hero__inner">
            <span className="hero__eyebrow" style={{ animation: 'fadeUp 0.8s 0.4s both' }}>
              {site.doctor.name} · Odontología Estética
            </span>
            <h1 className="hero__title" style={{ animation: 'fadeUp 0.9s 0.6s both' }}>
              Más que estética,<br /><em>es amor propio</em>
            </h1>
            <p className="hero__sub" style={{ animation: 'fadeUp 0.9s 0.8s both' }}>
              Transformaciones dentales personalizadas en {site.location.city}.<br />
              Cada sonrisa, una historia única.
            </p>
            <div className="hero__actions" style={{ animation: 'fadeUp 0.9s 1s both' }}>
              <Link to="/agendar" className="btn-primary">
                Agendar Cita
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
              </Link>
              <Link to="/casos" className="btn-secondary">Ver Casos</Link>
            </div>
          </div>
        </div>
      </section>

      {/* STATS */}
      <div className="stats-bar">
        <div className="container stats-bar__inner">
          {[['300+', 'Sonrisas transformadas'], ['5+', 'Años de experiencia'], ['100%', 'Enfoque estético'], ['Lun–Sáb', '8am – 8pm']].map(([n, l]) => (
            <div key={l} className="stat animate-fade-up">
              <span className="stat__num">{n}</span>
              <span className="stat__label">{l}</span>
            </div>
          ))}
        </div>
      </div>

      {/* SERVICIOS */}
      <section className="section section--services">
        <div className="container">
          <div className="section__header animate-fade-up">
            <span className="section-label">Especialidad</span>
            <div className="gold-line" />
            <h2 className="section-heading">Estética dental <em>personalizada</em></h2>
            <p className="section-desc">Cada tratamiento diseñado para realzar tu belleza natural con técnica y sensibilidad artística.</p>
          </div>
          <div className="services-grid">
            {servicios.map((s, i) => (
              <div key={s.title} className="service-card glass-card animate-fade-up" style={{ transitionDelay: `${i * 0.08}s` }}>
                <div className="service-card__img">
                  <img src={s.img} alt={s.title} />
                  <div className="service-card__img-overlay" />
                </div>
                <div className="service-card__body">
                  <h3 className="service-card__title">{s.title}</h3>
                  <p className="service-card__desc">{s.desc}</p>
                  <Link to="/servicios" className="service-card__link">
                    Conocer más
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                  </Link>
                </div>
              </div>
            ))}
          </div>
          <div className="section__cta animate-fade-up">
            <Link to="/servicios" className="btn-secondary">Ver todos los servicios</Link>
          </div>
        </div>
      </section>

      {/* CASOS PREVIEW */}
      <section className="section section--casos-preview">
        <div className="container">
          <div className="section__header animate-fade-up">
            <span className="section-label">Resultados reales</span>
            <div className="gold-line" />
            <h2 className="section-heading">Antes y <em>después</em></h2>
            <p className="section-desc">Arrastra el divisor para revelar la transformación real de cada paciente.</p>
          </div>
          <div className="casos-preview-grid animate-fade-up">
            {casosPreview.map((c, i) => (
              <MiniBeforeAfter key={i} antes={c.antes} despues={c.despues} titulo={c.titulo} />
            ))}
          </div>
          <div className="section__cta animate-fade-up">
            <Link to="/casos" className="btn-secondary">Ver todos los casos</Link>
          </div>
        </div>
      </section>

      {/* ABOUT */}
      <section className="section section--about">
        <div className="container about-split">
          <div className="about-split__imgs animate-fade-in">
            <div className="about-img about-img--main">
              <img src={doctorPerfil} alt={site.doctor.name} />
            </div>
            <div className="about-badge-wrap">
              <div className="about-badge">
                <span className="about-badge__label">{site.location.office}</span>
                <span className="about-badge__sub">{site.location.city}</span>
              </div>
            </div>
          </div>
          <div className="about-split__text animate-fade-up">
            <span className="section-label">El Doctor</span>
            <div className="gold-line" />
            <h2 className="section-heading">Pasión por la <em>estética dental</em></h2>
            <p className="about-text">{site.doctor.fullName} es odontólogo estético con enfoque en transformaciones dentales personalizadas. Su filosofía combina precisión técnica con sensibilidad artística para crear sonrisas únicas.</p>
            <p className="about-text">Ubicado en {site.location.street}, {site.location.city}, {site.location.state}. Cada caso es tratado con atención individualizada y compromiso total.</p>
            <Link to="/conocenos" className="btn-primary" style={{ marginTop: '2rem', display: 'inline-flex' }}>
              Conócelo
            </Link>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="section section--cta-agendar">
        <div className="container">
          <div className="cta-agendar animate-fade-up">
            <div className="cta-agendar__text">
              <span className="section-label">Primer paso</span>
              <h2 className="section-heading" style={{ marginBottom: '1rem' }}>
                Tu nueva sonrisa<br />empieza <em>hoy</em>
              </h2>
              <p style={{ color: 'var(--white-60)', lineHeight: '1.8', maxWidth: '460px', fontSize: '0.9rem' }}>
                Agenda tu consulta y descubramos juntos el tratamiento ideal para ti.
              </p>
            </div>
            <div className="cta-agendar__actions">
              <Link to="/agendar" className="btn-primary" style={{ fontSize: '0.84rem', padding: '1rem 2.25rem' }}>
                Agendar Cita
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
              </Link>
              <a href={site.contact.whatsapp} target="_blank" rel="noopener noreferrer" className="btn-secondary cta-wa">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>
                WhatsApp
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* MAPA */}
      <section className="section section--mapa">
        <div className="container">
          <div className="section__header animate-fade-up" style={{ textAlign: 'center', maxWidth: '600px', margin: '0 auto 2.5rem' }}>
            <span className="section-label">Ubicación</span>
            <div className="gold-line" style={{ margin: '0.6rem auto 1.4rem' }} />
            <h2 className="section-heading">{site.location.building}</h2>
            <p className="section-desc" style={{ margin: '0 auto' }}>{site.location.street} · {fullAddress()}.</p>
          </div>
          <div className="home-map-wrap animate-fade-up">
            <iframe
              title={`Ubicación ${site.doctor.name}`}
              src={site.location.mapsEmbedSrc}
              allowFullScreen
              loading="lazy"
              referrerPolicy="no-referrer-when-downgrade"
            />
          </div>
          <div className="home-map-actions animate-fade-up">
            <a href={site.location.mapsUrl} target="_blank" rel="noopener noreferrer" className="btn-primary">
              Cómo llegar
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
            </a>
          </div>
        </div>
      </section>

    </div>
  )
}
