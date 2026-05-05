import React, { useEffect, useState } from 'react'
import logo from '../assets/logo/logo.png'
import './Loader.css'

export default function Loader() {
  const [exiting, setExiting] = useState(false)

  useEffect(() => {
    const t = setTimeout(() => setExiting(true), 1700)
    return () => clearTimeout(t)
  }, [])

  return (
    <div className={`loader ${exiting ? 'loader--exit' : ''}`}>
      <div className="loader__inner">
        <div className="loader__logo-wrap">
          <img src={logo} alt="Dr. Diego Archila" className="loader__logo" />
        </div>
        <div className="loader__bar">
          <div className="loader__bar-fill" />
        </div>
        <p className="loader__text">Odontología Estética · Floridablanca</p>
      </div>
    </div>
  )
}
