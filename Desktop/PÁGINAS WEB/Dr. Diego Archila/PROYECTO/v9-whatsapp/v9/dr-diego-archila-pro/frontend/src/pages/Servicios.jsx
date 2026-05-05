import React from 'react'
import { Link } from 'react-router-dom'
import { useScrollAnimationAll } from '../hooks/useScrollAnimation'
import caso1d from '../assets/casos/caso1_despues.png'
import caso2d from '../assets/casos/caso2_despues.png'
import caso3d from '../assets/casos/caso3_despues.png'
import caso4d from '../assets/casos/caso4_despues.png'
import caso5d from '../assets/casos/caso5_despues.png'
import caso6d from '../assets/casos/caso6_despues.png'
import './Servicios.css'

const imgs = [caso1d, caso2d, caso3d, caso4d, caso5d, caso6d]

const servicios = [
  {
    icon: '✦', title: 'Diseño de Sonrisa', tagline: 'Tu identidad, redefinida',
    desc: 'El diseño de sonrisa es un proceso de transformación estética integral que armoniza perfectamente tu sonrisa con tus rasgos faciales únicos. Cada tratamiento es planificado con detalle para que el resultado sea predecible, natural y completamente personalizado.',
    beneficios: ['Análisis facial y dental completo', 'Resultado personalizado y predecible', 'Técnicas mínimamente invasivas', 'Materiales de alta calidad estética'],
    color: 'var(--accent)',
  },
  {
    icon: '◈', title: 'Carillas en Resina', tagline: 'Naturalidad en cada detalle',
    desc: 'Las carillas en resina estratificada son láminas ultrafinas que se adhieren a la superficie dental para corregir forma, color y tamaño. Un procedimiento mínimamente invasivo que ofrece resultados extraordinarios y de apariencia completamente natural.',
    beneficios: ['Procedimiento sin desgaste dental', 'Resultado natural e inmediato', 'Alta durabilidad y resistencia', 'Aplicación en una sola sesión'],
    color: 'var(--accent-light)',
  },
  {
    icon: '⬡', title: 'Blanqueamiento Dental', tagline: 'Luz en tu sonrisa',
    desc: 'El blanqueamiento dental profesional devuelve la luminosidad natural de tus dientes con resultados visibles desde la primera sesión. Un procedimiento seguro, controlado y personalizado según el tono natural y las necesidades de cada paciente.',
    beneficios: ['Resultados desde la primera sesión', 'Procedimiento seguro y controlado', 'Plan personalizado según tono dental', 'Mantenimiento a largo plazo'],
    color: 'var(--accent)',
  },
  {
    icon: '◉', title: 'Composite Dental', tagline: 'Restauraciones que se integran',
    desc: 'El composite dental es una resina de alta estética que permite restaurar, corregir y embellecer los dientes de forma directa. Ideal para cerrar diastemas, corregir irregularidades o restaurar fracturas con un acabado completamente natural.',
    beneficios: ['Restauración directa y rápida', 'Mimetiza el color natural del diente', 'Sin necesidad de laboratorio externo', 'Resultado inmediato en una sesión'],
    color: 'var(--accent-light)',
  },
  {
    icon: '⬟', title: 'Limpieza y Profilaxis', tagline: 'La base de todo tratamiento',
    desc: 'Una sonrisa sana es la base de una sonrisa estética. La limpieza profesional elimina el sarro, manchas y bacterias que la higiene diaria no puede remover, previniendo enfermedades periodontales y manteniendo tus tratamientos estéticos en perfecto estado.',
    beneficios: ['Eliminación completa de sarro', 'Pulido dental profesional', 'Detección temprana de problemas', 'Base para cualquier tratamiento estético'],
    color: 'var(--accent)',
  },
  {
    icon: '◇', title: 'Consulta de Valoración', tagline: 'El inicio de tu transformación',
    desc: 'Cada transformación comienza con una valoración personalizada. En esta consulta analizamos tu caso en detalle, escuchamos tus objetivos y diseñamos el plan de tratamiento ideal para conseguir la sonrisa que llevas imaginando.',
    beneficios: ['Análisis fotográfico completo', 'Plan de tratamiento personalizado', 'Sin compromiso ni presión', 'Orientación honesta y directa'],
    color: 'var(--accent-light)',
  },
]

export default function Servicios() {
  useScrollAnimationAll()

  return (
    <div className="servicios-page">
      <section className="page-hero">
        <div className="container">
          <div className="page-hero__content animate-fade-up">
            <span className="section-label">Tratamientos</span>
            <div className="gold-line" />
            <h1 className="page-hero__title">Estética dental <em>a tu medida</em></h1>
            <p className="page-hero__sub">Cada tratamiento pensado para realzar tu sonrisa de forma natural, precisa y personalizada.</p>
          </div>
        </div>
      </section>

      <section className="servicios-list">
        <div className="container">
          {servicios.map((s, i) => (
            <div key={s.title} className={`servicio-item animate-fade-up ${i % 2 !== 0 ? 'servicio-item--reverse' : ''}`}>
              <div className="servicio-item__visual">
                <div className="servicio-item__img-wrap">
                  <img src={imgs[i]} alt={s.title} />
                  <div className="servicio-item__img-overlay" />
                </div>
                <div className="servicio-item__number">{String(i + 1).padStart(2, '0')}</div>
              </div>
              <div className="servicio-item__content">
                <span className="servicio-item__tagline" style={{ color: s.color }}>{s.tagline}</span>
                <h2 className="servicio-item__title">{s.title}</h2>
                <p className="servicio-item__desc">{s.desc}</p>
                <ul className="servicio-item__beneficios">
                  {s.beneficios.map((b) => (
                    <li key={b}>
                      <span style={{ color: s.color }}>—</span>
                      {b}
                    </li>
                  ))}
                </ul>
                <Link to="/agendar" className="btn-primary" style={{ marginTop: '2rem', fontSize: '0.78rem' }}>
                  Agendar consulta
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </Link>
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
