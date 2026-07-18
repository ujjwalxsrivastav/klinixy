// components/QuestionCard.jsx

function QuestionCard({
  question,
  options,
  onAnswer,
}) {

  return (

    <div className="w-full">

      {/* Heading */}
      <div className="text-center mb-12">

        <p className="text-blue-600 font-semibold mb-3">
          Skin Care Analysis
        </p>

        <h1 className="text-4xl md:text-5xl font-bold text-gray-900 leading-tight">

          Discover Your Perfect
          Skincare Routine

        </h1>

        <p className="text-gray-600 mt-5 max-w-2xl mx-auto leading-8">

          Answer a few simple questions and
          get personalized skincare product
          recommendations based on your skin type.

        </p>

      </div>

      {/* Question */}
      <h2 className="text-3xl md:text-4xl font-bold text-gray-900 leading-tight mb-10">

        {question}

      </h2>

      {/* Options */}
      <div className="grid gap-5">

        {options.map((option, index) => (

          <button
            key={index}
            onClick={() => onAnswer(option)}
            className="w-full border border-gray-300 hover:border-blue-500 hover:bg-blue-50 transition duration-300 py-5 px-6 rounded-2xl text-left text-lg font-medium text-gray-700"
          >

            {option}

          </button>

        ))}

      </div>

    </div>
  );
}

export default QuestionCard;