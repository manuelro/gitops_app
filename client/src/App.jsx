const API_BASE = import.meta.env.VITE_API_BASE_URL || '/api';

export default function App() {
  return (
    <main className="container">
      <h1>Demo Client - TEST TEXT 5</h1>
      <p>Static React app served by NGINX.</p>
      <p>Try API version: {`${API_BASE}/version`}</p>
    </main>
  );
}
