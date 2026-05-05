import React, { useState, useEffect } from 'react'
import { Link, NavLink, useLocation } from 'react-router-dom'
import logo from '../assets/logo/logo.png'
import './Header.css'

const navItems = [
  { label: 'Inicio', path: '/' },
  { label: 'Servicios', path: '/servicios' },
  { label: 'Casos', path: '/casos' },
  { label: 'Conócenos', path: '/conocenos' },
  { label: 'Contacto', path: '/contacto' },
]

export default function Header() {
  const [scrolled, setScrolled] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const location = useLocation()

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => { setMobileOpen(false) }, [location])

  return (
    <header className={`header ${scrolled ? 'header--scrolled' : ''}`}>
      <div className="header__inner container">
        <Link to="/" className="header__logo">
          <img src={logo} alt="Dr. Diego Archila" />
        </Link>

        <nav className="header__nav">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => `header__nav-link ${isActive ? 'active' : ''}`}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <Link to="/agendar" className="header__cta btn-primary">
          Agendar Cita
        </Link>

        <button
          className={`header__burger ${mobileOpen ? 'open' : ''}`}
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label="Menú"
        >
          <span /><span /><span />
        </button>
      </div>

      <div className={`header__mobile ${mobileOpen ? 'open' : ''}`}>
        {navItems.map((item) => (
          <Link key={item.path} to={item.path} className="header__mobile-link">
            {item.label}
          </Link>
        ))}
        <Link to="/agendar" className="btn-primary" style={{ marginTop: '1rem', justifyContent: 'center' }}>
          Agendar Cita
        </Link>
      </div>
    </header>
  )
}
