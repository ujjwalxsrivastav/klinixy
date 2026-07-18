// components/ResultCard.jsx

function ResultCard({
  skinType,
  routine,
  onRestart,
}) {

  return (

    <div className="w-full text-center">

      {/* Heading */}
      <p className="text-blue-600 font-semibold mb-4">
        Skin Analysis Complete
      </p>

      <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6 leading-tight">

        Your Skin Type:
        <span className="text-blue-600">
          {" "}
          {skinType}
        </span>

      </h2>

      <p className="text-gray-600 leading-8 max-w-2xl mx-auto mb-12">

        Based on your answers, here is your
        personalized skincare routine for
        healthy and glowing skin.

      </p>

      {/* Morning Routine */}
      <div className="bg-orange-50 border border-orange-100 rounded-3xl p-8 mb-8 text-left">

        <h3 className="text-2xl font-bold text-gray-900 mb-6">
          🌞 Morning Routine
        </h3>

        <div className="space-y-5">

          {routine.morning.map((step, index) => (

            <div
              key={index}
              className="bg-white rounded-2xl p-5 shadow-sm"
            >

              <p className="text-sm text-blue-600 font-semibold mb-2">
                STEP {index + 1}
              </p>

              <h4 className="text-lg font-bold text-gray-800 mb-2">
                {step.title}
              </h4>

              <p className="text-gray-600 leading-7">
                {step.description}
              </p>

            </div>

          ))}

        </div>

      </div>

      {/* Night Routine */}
      <div className="bg-blue-50 border border-blue-100 rounded-3xl p-8 mb-8 text-left">

        <h3 className="text-2xl font-bold text-gray-900 mb-6">
          🌙 Night Routine
        </h3>

        <div className="space-y-5">

          {routine.night.map((step, index) => (

            <div
              key={index}
              className="bg-white rounded-2xl p-5 shadow-sm"
            >

              <p className="text-sm text-blue-600 font-semibold mb-2">
                STEP {index + 1}
              </p>

              <h4 className="text-lg font-bold text-gray-800 mb-2">
                {step.title}
              </h4>

              <p className="text-gray-600 leading-7">
                {step.description}
              </p>

            </div>

          ))}

        </div>

      </div>

      {/* Tips */}
      <div className="bg-green-50 border border-green-100 rounded-3xl p-8 text-left">

        <h3 className="text-2xl font-bold text-gray-900 mb-5">
          💡 Extra Tips
        </h3>

        <ul className="space-y-4">

          {routine.tips.map((tip, index) => (

            <li
              key={index}
              className="text-gray-700 leading-7"
            >
              • {tip}
            </li>

          ))}

        </ul>

      </div>

      {/* Restart Button */}
      {/* <button
        onClick={onRestart}
        className="mt-12 bg-blue-600 hover:bg-blue-700 text-white px-10 py-4 rounded-2xl text-lg font-semibold transition duration-300 shadow-lg"
      >

        Retake Quiz

      </button> */}

    </div>
  );
}

export default ResultCard;