import React, { useRef, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useScrollAnimationAll } from '../hooks/useScrollAnimation'
import { site } from '../config/site'
import doctorPerfil from '../assets/doctor/perfil.png'
import doctorCasual from '../assets/doctor/casual.jpg'
import videoExp from '../assets/videos/exp2.mp4'
import './Conocenos.css'

const valores = [
  { icon: '✦', title: 'Estética personalizada', desc: 'Cada tratamiento diseñado desde cero para cada persona, considerando sus rasgos, gustos y objetivos únicos.' },
  { icon: '◈', title: 'Atención directa', desc: 'Trato personal y directo con el Dr. Diego en cada consulta. Sin intermediarios, sin protocolos genéricos.' },
  { icon: '⬡', title: 'Mínima invasión', desc: 'Filosofía de conservar al máximo la estructura dental natural, interviniendo solo lo necesario.' },
  { icon: '◉', title: 'Resultados reales', desc: 'Cada caso documentado y ejecutado con compromiso total hacia el resultado más natural y duradero posible.' },
]

export default function Conocenos() {
  useScrollAnimationAll()
  const videoRef = useRef(null)

  useEffect(() => {
    if (videoRef.current) videoRef.current.play().catch(() => {})
  }, [])

  return (
    <div className="conocenos-page">
      <section className="page-hero">
        <div className="container">
          <div className="page-hero__content animate-fade-up">
            <span className="section-label">El doctor</span>
            <div className="gold-line" />
            <h1 className="page-hero__title">Dr. Diego <em>Archila</em></h1>
            <p className="page-hero__sub">Odontólogo estético con enfoque en transformaciones dentales personalizadas y amor por el detalle.</p>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container conocenos-bio-split">
          <div className="conocenos-bio__imgs animate-fade-in">
            <div className="conocenos-bio__img-main">
              <img src={doctorPerfil} alt="Dr. Diego Archila" />
            </div>
            <div className="conocenos-bio__img-secondary">
              <img src={doctorCasual} alt="Dr. Diego Archila" />
            </div>
          </div>
          <div className="conocenos-bio__text animate-fade-up">
            <span className="section-label">Biografía</span>
            <div className="gold-line" />
            <h2 className="section-heading">Pasión por <em>transformar vidas</em></h2>
            <p className="bio-text">El {site.doctor.fullName} es odontólogo estético radicado en {site.location.city}, {site.location.state}. Con años de dedicación al campo de la estética dental, ha desarrollado una filosofía de trabajo centrada en la individualidad de cada paciente.</p>
            <p className="bio-text">Su enfoque combina técnica depurada con sensibilidad artística, entendiendo que una sonrisa no es solo el resultado de un procedimiento, sino la expresión más auténtica de quien eres.</p>
            <p className="bio-text">Con la frase que guía su práctica, "{site.doctor.phrase}", el Dr. Archila busca que cada persona que pasa por su consultorio salga con mucho más que una sonrisa: con confianza renovada.</p>
            <div className="bio-phrase">
              <span>"{site.doctor.phrase}"</span>
            </div>
            <Link to="/agendar" className="btn-primary" style={{ marginTop: '2rem', display: 'inline-flex' }}>
              Agendar una consulta
            </Link>
          </div>
        </div>
      </section>

      <section className="section conocenos-valores-section">
        <div className="container">
          <div className="section__header animate-fade-up" style={{ textAlign: 'center', maxWidth: '600px', margin: '0 auto 3.5rem' }}>
            <span className="section-label">Filosofía</span>
            <div className="gold-line" style={{ margin: '0.6rem auto 1.4rem' }} />
            <h2 className="section-heading">Lo que guía <em>cada tratamiento</em></h2>
          </div>
          <div className="valores-grid">
            {valores.map((v, i) => (
              <div key={v.title} className="valor-card glass-card animate-fade-up" style={{ transitionDelay: `${i * 0.1}s` }}>
                <span className="valor-icon">{v.icon}</span>
                <h3 className="valor-title">{v.title}</h3>
                <p className="valor-desc">{v.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section conocenos-video-section">
        <div className="container">
          <div className="conocenos-video-wrap animate-fade-up">
            <div className="conocenos-video-text">
              <span className="section-label">Propósito</span>
              <div className="gold-line" />
              <h2 className="section-heading">Ver hasta el final —<br /><em>este es mi propósito</em></h2>
              <p style={{ color: 'var(--white-60)', fontSize: '0.9rem', lineHeight: '1.85', marginTop: '1rem' }}>
                Detrás de cada caso hay una historia. El {site.doctor.name} comparte su visión de lo que significa transformar una sonrisa y por qué la odontología estética va mucho más allá del diente.
              </p>
              <Link to="/agendar" className="btn-primary" style={{ marginTop: '2rem', display: 'inline-flex' }}>
                Agendar cita
              </Link>
            </div>
            <div className="conocenos-video-player">
              {/* muted al iniciar — el usuario activa el sonido manualmente. */}
              <video ref={videoRef} autoPlay loop muted playsInline controls preload="metadata">
                <source src={videoExp} type="video/mp4" />
              </video>
            </div>
          </div>
        </div>
      </section>

      <section className="section conocenos-ubicacion-section">
        <div className="container">
          <div className="section__header animate-fade-up" style={{ textAlign: 'center', maxWidth: '600px', margin: '0 auto 3rem' }}>
            <span className="section-label">Ubicación</span>
            <div className="gold-line" style={{ margin: '0.6rem auto 1.4rem' }} />
            <h2 className="section-heading">{site.location.building}</h2>
          </div>
          <div className="ubicacion-info animate-fade-up">
            <div className="ubicacion-detail">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
              <span>{site.location.street}, {site.location.office}<br />{site.location.building}<br />{site.location.city}, {site.location.state}</span>
            </div>
            <div className="ubicacion-detail">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
              <span>Lunes a Sábado: 8:00 a.m. – 8:00 p.m.<br />Domingo: Cerrado</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
