// Footer.jsx
 import logo from "../assets/logu.png"
import {
  FaFacebookF,
  FaInstagram,
  FaLinkedinIn,
  FaTwitter,
} from "react-icons/fa";

function Footer() {
  return (
    <footer className="w-full bg-gray-950 text-white px-8 md:px-16 pt-20 pb-10">

      <div className="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">

        {/* Brand */}
        <div>

        
               <div className="flex items-center justify-center">
            <img 
              src={logo} 
              alt="Klinixy Logo" 
              className="h-12   hover:opacity-90 transition-opacity" 
            />
             </div>

          <p className="text-gray-400 leading-8">
            Smart healthcare solutions for modern lifestyles.
            Manage medicines, nutrition and wellness
            all in one platform.
          </p>

          {/* Social Icons */}
          <div className="flex items-center gap-4 mt-8">

            <div className="w-10 h-10 rounded-full bg-gray-800 hover:bg-blue-600 transition duration-300 flex items-center justify-center cursor-pointer">
              <FaFacebookF />
            </div>

            <div className="w-10 h-10 rounded-full bg-gray-800 hover:bg-pink-500 transition duration-300 flex items-center justify-center cursor-pointer">
              <FaInstagram />
            </div>

            <div className="w-10 h-10 rounded-full bg-gray-800 hover:bg-blue-500 transition duration-300 flex items-center justify-center cursor-pointer">
              <FaTwitter />
            </div>

            <div className="w-10 h-10 rounded-full bg-gray-800 hover:bg-blue-700 transition duration-300 flex items-center justify-center cursor-pointer">
              <FaLinkedinIn />
            </div>

          </div>

        </div>

        {/* Company */}
        <div>

          <h3 className="text-xl font-semibold mb-6">
            Company
          </h3>

          <ul className="space-y-4 text-gray-400">

            <li className="hover:text-white cursor-pointer transition">
              About Us
            </li>

            <li className="hover:text-white cursor-pointer transition">
              Features
            </li>

            <li className="hover:text-white cursor-pointer transition">
              Careers
            </li>

            <li className="hover:text-white cursor-pointer transition">
              Blog
            </li>

          </ul>

        </div>

        {/* Support */}
        <div>

          <h3 className="text-xl font-semibold mb-6">
            Support
          </h3>

          <ul className="space-y-4 text-gray-400">

            <li className="hover:text-white cursor-pointer transition">
              Help Center
            </li>

            <li className="hover:text-white cursor-pointer transition">
              Privacy Policy
            </li>

            <li className="hover:text-white cursor-pointer transition">
              Terms & Conditions
            </li>

            <li className="hover:text-white cursor-pointer transition">
              Contact Support
            </li>

          </ul>

        </div>

        {/* Newsletter */}
        <div>

          <h3 className="text-xl font-semibold mb-6">
            Newsletter
          </h3>

          <p className="text-gray-400 leading-7 mb-6">
            Subscribe to get health tips,
            updates and latest features.
          </p>

          <div className="flex flex-col gap-4">

            <input
              type="email"
              placeholder="Enter your email"
              className="bg-gray-900 border border-gray-700 rounded-xl px-4 py-3 outline-none focus:border-blue-500"
            />

            <button className="bg-blue-600 hover:bg-blue-700 py-3 rounded-xl transition duration-300">
              Subscribe
            </button>

          </div>

        </div>

      </div>

      {/* Bottom */}
      <div className="border-t border-gray-800 mt-16 pt-8 text-center text-gray-500">

        <p>
          © 2026 KLINIXY. All Rights Reserved.
        </p>

      </div>

    </footer>
  );
}

export default Footer;