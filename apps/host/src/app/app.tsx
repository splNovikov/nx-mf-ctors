import * as React from 'react';
import { Link, Route, Routes } from 'react-router-dom';

const VacationPay = React.lazy(() => import('vacationPay/Module'));

const Host = () => <div>HOST?</div>

export function App() {
  return (
    <React.Suspense fallback={null}>
      <ul>
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
      </Routes>
    </React.Suspense>
  );
}

export default App;
