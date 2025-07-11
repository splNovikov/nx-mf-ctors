import * as React from 'react';
import { Link, Route, Routes } from 'react-router-dom';

const Remote = React.lazy(() => import('remote/Module'));

const Blyat = () => <div>Blyat</div>

export function App() {
  return (
    <React.Suspense fallback={null}>
      <ul>
        <li>
          <Link to="/">Home</Link>
        </li>
        <li>
          <Link to="/remote">Remote</Link>
        </li>
      </ul>
      <Routes>
        <Route path="/" element={<Blyat />} />
        <Route path="/remote" element={<Remote />} />
      </Routes>
    </React.Suspense>
  );
}

export default App;
