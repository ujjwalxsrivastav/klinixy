// CTA.jsx

function CTA() {
  return (
    <section id="cta" className="w-full px-8 md:px-16 py-24 bg-blue-50">

      <div className="max-w-7xl mx-auto bg-gradient-to-r from-blue-600 to-indigo-600 rounded-[40px] px-8 md:px-16 py-16 md:py-24 text-center shadow-2xl">

        {/* Small Text */}
        <p className="text-blue-100 font-semibold mb-4 tracking-wide">
          START YOUR HEALTH JOURNEY TODAY
        </p>

        {/* Heading */}
        <h2 className="text-4xl md:text-6xl font-bold text-white leading-tight max-w-4xl mx-auto">
          Better Health Begins With
          Smarter Healthcare Solutions
        </h2>

        {/* Description */}
        <p className="text-blue-100 text-lg leading-8 max-w-2xl mx-auto mt-8">
          Join thousands of users managing medicines,
          nutrition and wellness with our modern
          healthcare platform.
        </p>

        {/* Buttons */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-5 mt-12">

          <a href="https://app.klinixy.com" target="_blank" rel="noopener noreferrer" className="bg-white text-blue-600 hover:bg-blue-100 px-8 py-4 rounded-2xl text-lg font-semibold transition duration-300 shadow-lg inline-block text-center">
            Order Now
          </a>

          <button className="border-2 border-white text-white hover:bg-white hover:text-blue-600 px-8 py-4 rounded-2xl text-lg font-semibold transition duration-300">
            Learn More
          </button>

        </div>

        {/* Stats */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-10 mt-16 text-white">

          <div>
            <h3 className="text-4xl font-bold">
              10K+
            </h3>

            <p className="text-blue-100 mt-2">
              Active Users
            </p>
          </div>

          <div>
            <h3 className="text-4xl font-bold">
              500+
            </h3>

            <p className="text-blue-100 mt-2">
              Healthcare Experts
            </p>
          </div>

          <div>
            <h3 className="text-4xl font-bold">
              99%
            </h3>

            <p className="text-blue-100 mt-2">
              Customer Satisfaction
            </p>
          </div>

        </div>

      </div>

    </section>
  );
}

export default CTA;