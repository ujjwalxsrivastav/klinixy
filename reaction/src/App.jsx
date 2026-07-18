import { useState } from "react";

import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

import Hero from "./sections/Hero";
import Features from "./sections/Features";
import Reviews from "./sections/Reviews";
import CTA from "./sections/CTA";

import "./index.css";
import SkinQuiz from "./components/SkinQuiz";
import DietitianWidget from "./components/DietitianWidget";

function App() {

  const [user, setUser] = useState(
    JSON.parse(localStorage.getItem("user"))
  );

  return (

    <div className="app">

      <Navbar
        user={user}
        setUser={setUser}
      />

      <main>
        <Hero />
        <Features />
        <Reviews
          user={user}
          setUser={setUser}
        />
        <SkinQuiz/>
        <DietitianWidget/>
        <CTA />
      </main>

      <Footer />

    </div>
  );
}

export default App;