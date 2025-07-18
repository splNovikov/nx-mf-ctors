import * as React from 'react';
import { Link, Route, Routes } from 'react-router-dom';

import styles from './app.module.scss'

const VacationPay = React.lazy(() => import('vacationPay/Module'));

const Host = () => <div>HOST</div>

// Компонент для обработки неизвестных маршрутов
const NotFound = () => (
  <div style={{ 
    textAlign: 'center', 
    padding: '2rem',
    maxWidth: '600px',
    margin: '0 auto'
  }}>
    <h1 style={{ fontSize: '4rem', color: '#e74c3c', marginBottom: '1rem' }}>404</h1>
    <h2 style={{ marginBottom: '1rem' }}>Страница не найдена</h2>
    <p style={{ marginBottom: '2rem', color: '#666' }}>
      Извините, но запрашиваемая страница не существует.
    </p>
    <Link 
      to="/" 
      style={{
        display: 'inline-block',
        padding: '0.75rem 1.5rem',
        backgroundColor: '#3498db',
        color: 'white',
        textDecoration: 'none',
        borderRadius: '4px',
        transition: 'background-color 0.3s'
      }}
    >
      Вернуться на главную
    </Link>
  </div>
);

export function App() {
  return (
    <React.Suspense fallback={null}>
      <ul className={styles.nav}>
        <li>
          <Link to="/">Home</Link>
        </li>
        <li>
          <Link to="/vacation-pay">VacationPay</Link>
        </li>
      </ul>
      <Routes>
        <Route path="/" element={<Host />} />
        <Route path="/vacation-pay" element={<VacationPay />} />
        {/* Catch-all роут для обработки всех неизвестных маршрутов */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </React.Suspense>
  );
}

export default App;
