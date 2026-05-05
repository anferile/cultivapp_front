import React from 'react'
import { Link } from 'react-router-dom'
import './NotFound.css'

export default function NotFound() {
  return (
    <div className="notfound">
      <div className="notfound__inner">
        <span className="notfound__code">404</span>
        <h1 className="notfound__title">Página no encontrada</h1>
        <p className="notfound__sub">La página que buscas no existe o fue movida.</p>
        <Link to="/" className="btn-primary">Volver al inicio</Link>
      </div>
    </div>
  )
}
