import React from 'react'
import { Link } from 'react-router-dom'
import logo from '../assets/logo/logo.png'
import { site, addressLines } from '../config/site'
import './Footer.css'

export default function Footer() {
  const lines = addressLines()
  return (
    <footer className="footer">
      <div className="footer__top container">
        <div className="footer__brand">
          <img src={logo} alt={site.doctor.name} className="footer__logo" />
          <p className="footer__tagline">
            {site.doctor.profession}<br />
            {site.location.city}, {site.location.state}
          </p>
          <p className="footer__phrase">"{site.doctor.phrase}"</p>
          <div className="footer__social">
            <a href={site.contact.instagram} target="_blank" rel="noopener noreferrer" className="footer__social-link" aria-label="Instagram">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><rect x="2" y="2" width="20" height="20" rx="5"/><circle cx="12" cy="12" r="5"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none"/></svg>
            </a>
            <a href={site.contact.facebook} target="_blank" rel="noopener noreferrer" className="footer__social-link" aria-label="Facebook">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M18 2h-3a5 5 0 00-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 011-1h3z"/></svg>
            </a>
            <a href={site.contact.whatsapp} target="_blank" rel="noopener noreferrer" className="footer__social-link" aria-label="WhatsApp">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z"/></svg>
            </a>
          </div>
        </div>

        <div className="footer__col">
          <h4>Navegación</h4>
          <ul>
            <li><Link to="/">Inicio</Link></li>
            <li><Link to="/servicios">Servicios</Link></li>
            <li><Link to="/casos">Casos Clínicos</Link></li>
            <li><Link to="/conocenos">Conócenos</Link></li>
            <li><Link to="/contacto">Contacto</Link></li>
          </ul>
        </div>

        <div className="footer__col">
          <h4>Contacto</h4>
          <ul className="footer__info">
            <li>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
              <span>{lines.map((l, i) => <React.Fragment key={i}>{l}{i < lines.length - 1 ? <br /> : null}</React.Fragment>)}</span>
            </li>
            <li>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6A19.79 19.79 0 012.12 4.18 2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
              {site.contact.phone}
            </li>
            <li>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
              <span>
                Lun–Sáb: 8:00 a.m. – 8:00 p.m.<br />
                Domingo: Cerrado<br />
                <span className="footer__cita-hint">Atención únicamente con cita previa</span>
              </span>
            </li>
          </ul>
        </div>

        <div className="footer__col">
          <h4>Cita Rápida</h4>
          <p className="footer__cita-desc">
            Agenda tu consulta y da el primer paso hacia la sonrisa que mereces.
          </p>
          <Link to="/agendar" className="btn-primary footer__cita-btn">
            Agendar Cita
          </Link>
        </div>
      </div>

      <div className="footer__bottom container">
        <p>© {new Date().getFullYear()} {site.doctor.fullName}. Todos los derechos reservados.</p>
        <a
          className="footer__bottom-link"
          href={site.developer.url}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="GitHub del desarrollador"
        >
          <svg viewBox="0 0 24 24" width="13" height="13" fill="currentColor" aria-hidden="true"><path d="M12 .297a12 12 0 00-3.79 23.39c.6.11.82-.26.82-.58v-2.03c-3.34.73-4.04-1.61-4.04-1.61-.55-1.39-1.34-1.76-1.34-1.76-1.09-.74.08-.73.08-.73 1.21.09 1.84 1.24 1.84 1.24 1.07 1.84 2.81 1.31 3.5 1 .11-.78.42-1.31.76-1.61-2.66-.3-5.47-1.33-5.47-5.93 0-1.31.47-2.38 1.24-3.22-.13-.3-.54-1.52.12-3.18 0 0 1.01-.32 3.3 1.23a11.5 11.5 0 016 0c2.29-1.55 3.3-1.23 3.3-1.23.66 1.66.25 2.88.12 3.18.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.62-5.49 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0012 .297"/></svg>
          {site.developer.label}
        </a>
      </div>
    </footer>
  )
}
