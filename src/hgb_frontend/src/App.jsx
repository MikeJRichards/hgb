import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Navbar from './components/Navbar';
import Home from './Home';
import Swap from './Swap';
import './index.scss';
import {exchange} from '../../declarations/exchange';

const App = () => (
  <>
    <Navbar/>
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/swap" element={<Swap />} />
      </Routes>
    </Router>
  </>
);

export default App;
