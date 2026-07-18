// Features.jsx

import { FaHeartbeat, FaUserMd, FaAppleAlt, FaBell } from "react-icons/fa";

function Features() {
  return (
    <section id="features" className="w-full px-8 md:px-16 py-24 bg-white">

      {/* Heading */}
      <div className="text-center mb-16">

        <p className="text-blue-600 font-semibold mb-3">
          Our Features
        </p>

        <h2 className="text-4xl md:text-5xl font-bold text-gray-900">
          Healthcare Made Simple
        </h2>

        <p className="text-gray-600 mt-5 max-w-2xl mx-auto leading-8">
          Everything you need to manage your health,
          nutrition, medicines and prescriptions in one platform.
        </p>

      </div>

      {/* Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">

        {/* Card 1 */}
        <div className="bg-blue-50 p-8 rounded-3xl hover:-translate-y-2 transition duration-300 shadow-sm hover:shadow-xl">

          <div className="w-16 h-16 rounded-2xl bg-blue-600 text-white flex items-center justify-center text-2xl mb-6">
            <FaHeartbeat />
          </div>

          <h3 className="text-2xl font-semibold text-gray-900 mb-4">
            Health Tracking
          </h3>

          <p className="text-gray-600 leading-7">
            Monitor your daily health activities,
            vitals and wellness progress easily.
          </p>

        </div>

        {/* Card 2 */}
        <div className="bg-blue-50 p-8 rounded-3xl hover:-translate-y-2 transition duration-300 shadow-sm hover:shadow-xl">

          <div className="w-16 h-16 rounded-2xl bg-blue-600 text-white flex items-center justify-center text-2xl mb-6">
            <FaUserMd />
          </div>

          <h3 className="text-2xl font-semibold text-gray-900 mb-4">
            Doctor Support
          </h3>

          <p className="text-gray-600 leading-7">
            Connect with healthcare experts
            and get trusted medical guidance.
          </p>

        </div>

        {/* Card 3 */}
        <div className="bg-blue-50 p-8 rounded-3xl hover:-translate-y-2 transition duration-300 shadow-sm hover:shadow-xl">

          <div className="w-16 h-16 rounded-2xl bg-blue-600 text-white flex items-center justify-center text-2xl mb-6">
            <FaAppleAlt />
          </div>

          <h3 className="text-2xl font-semibold text-gray-900 mb-4">
            Nutrition Plans
          </h3>

          <p className="text-gray-600 leading-7">
            Personalized nutrition and diet plans
            tailored to your lifestyle.
          </p>

        </div>

        {/* Card 4 */}
        <div className="bg-blue-50 p-8 rounded-3xl hover:-translate-y-2 transition duration-300 shadow-sm hover:shadow-xl">

          <div className="w-16 h-16 rounded-2xl bg-blue-600 text-white flex items-center justify-center text-2xl mb-6">
            <FaBell />
          </div>

          <h3 className="text-2xl font-semibold text-gray-900 mb-4">
            Medicine Reminders
          </h3>

          <p className="text-gray-600 leading-7">
            Never miss your medicines with
            smart notifications and reminders.
          </p>

        </div>

      </div>

    </section>
  );
}

export default Features;
