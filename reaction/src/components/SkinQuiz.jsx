// SkinQuiz.jsx
import QuestionCard from "../components/QuestionCard";
import ResultCard from "../components/ResultCard";
import { useState } from "react";

function SkinQuiz() {

  const questions = [

    {
      question: "How does your skin feel after washing?",
      options: [
        "Dry & Tight",
        "Soft & Normal",
        "Oily & Shiny",
      ],
    },

    {
      question: "How often do you get acne?",
      options: [
        "Never",
        "Sometimes",
        "Very Often",
      ],
    },

    {
      question: "How sensitive is your skin?",
      options: [
        "Very Sensitive",
        "Slightly Sensitive",
        "Not Sensitive",
      ],
    },

    {
      question: "What is your biggest skin concern?",
      options: [
        "Acne",
        "Dryness",
        "Dark Spots",
        "Oiliness",
      ],
    },

  ];

  const [currentQuestion, setCurrentQuestion] =
    useState(0);

  const [answers, setAnswers] =
    useState([]);

  const [showResult, setShowResult] =
    useState(false);

  // HANDLE ANSWER
  const handleAnswer = (option) => {

    const updatedAnswers = [
      ...answers,
      option,
    ];

    setAnswers(updatedAnswers);

    // NEXT QUESTION
    if (
      currentQuestion + 1 <
      questions.length
    ) {

      setCurrentQuestion(
        currentQuestion + 1
      );

    } else {

      setShowResult(true);
    }
  };

 // DETECT SKIN TYPE
const getSkinType = () => {

  const oilyCount =
    answers.filter(
      (a) =>
        a.includes("Oily") ||
        a.includes("Very Often")
    ).length;

  const dryCount =
    answers.filter(
      (a) =>
        a.includes("Dry")
    ).length;

  // OILY SKIN
  if (oilyCount >= 2) {

    return {

      type: "Oily Skin",

      routine: {

        morning: [

          {
            title: "Cleanser",
            description:
              "Wash your face with a Salicylic Acid face wash to remove excess oil and dirt.",
          },

          {
            title: "Serum",
            description:
              "Apply a Niacinamide serum to control oil and reduce acne marks.",
          },

          {
            title: "Moisturizer",
            description:
              "Use a lightweight oil-free moisturizer for hydration.",
          },

          {
            title: "Sunscreen",
            description:
              "Apply SPF 50 sunscreen before going outside.",
          },

        ],

        night: [

          {
            title: "Face Wash",
            description:
              "Clean your skin properly to remove pollution and oil buildup.",
          },

          {
            title: "Treatment",
            description:
              "Apply acne treatment or salicylic acid serum.",
          },

          {
            title: "Moisturizer",
            description:
              "Use a gel-based night moisturizer.",
          },

        ],

        tips: [

          "Drink plenty of water daily.",

          "Avoid touching your face repeatedly.",

          "Do not over-wash your face.",

        ],

      },

    };

  }

  // DRY SKIN
  if (dryCount >= 2) {

    return {

      type: "Dry Skin",

      routine: {

        morning: [

          {
            title: "Cleanser",
            description:
              "Use a gentle hydrating cleanser to clean your face.",
          },

          {
            title: "Serum",
            description:
              "Apply Hyaluronic Acid serum for deep hydration.",
          },

          {
            title: "Moisturizer",
            description:
              "Use a Ceramide-based moisturizer to lock moisture.",
          },

          {
            title: "Sunscreen",
            description:
              "Apply SPF sunscreen to protect dry skin from damage.",
          },

        ],

        night: [

          {
            title: "Face Wash",
            description:
              "Clean your face using a non-foaming cleanser.",
          },

          {
            title: "Hydration",
            description:
              "Apply a nourishing hydration serum.",
          },

          {
            title: "Night Cream",
            description:
              "Use a thick night cream before sleeping.",
          },

        ],

        tips: [

          "Avoid very hot water on face.",

          "Use moisturizer immediately after washing face.",

          "Drink enough water daily.",

        ],

      },

    };

  }

  // NORMAL SKIN
  return {

    type: "Normal Skin",

    routine: {

      morning: [

        {
          title: "Cleanser",
          description:
            "Use a gentle daily cleanser.",
        },

        {
          title: "Vitamin C",
          description:
            "Apply Vitamin C serum for glowing skin.",
        },

        {
          title: "Moisturizer",
          description:
            "Use a lightweight moisturizer.",
        },

        {
          title: "Sunscreen",
          description:
            "Apply SPF 30 sunscreen daily.",
        },

      ],

      night: [

        {
          title: "Clean Face",
          description:
            "Wash face properly before sleeping.",
        },

        {
          title: "Hydration",
          description:
            "Apply light hydration serum.",
        },

        {
          title: "Night Cream",
          description:
            "Use a gentle night cream.",
        },

      ],

      tips: [

        "Maintain a healthy diet.",

        "Sleep at least 7-8 hours.",

        "Stay hydrated.",

      ],

    },

  };

};

  const result =
    getSkinType();

  return (

    <section id="skin" className="w-full px-6 md:px-16 py-24 bg-gradient-to-b from-blue-50 to-white">

      <div className="max-w-3xl mx-auto bg-white rounded-[35px] shadow-xl p-8 md:p-12">

        {!showResult ? (

          <>

            {/* Progress */}
            <div className="mb-8">

              <div className="flex justify-between mb-3">

                <p className="text-blue-600 font-medium">
                  Question {currentQuestion + 1}
                </p>

                <p className="text-gray-500">
                  {questions.length}
                </p>

              </div>

              <div className="w-full h-3 bg-gray-200 rounded-full overflow-hidden">

                <div
                  className="h-full bg-blue-600 transition-all duration-500"
                  style={{
                    width: `${
                      ((currentQuestion + 1) /
                        questions.length) *
                      100
                    }%`,
                  }}
                ></div>

              </div>

            </div>


       
        <QuestionCard
         question={
           questions[currentQuestion]
             .question
         }
         options={
           questions[currentQuestion]
             .options
         }
         onAnswer={handleAnswer}
       />
        

          </>

        ) : (

          <>

            {/* Result */}
        <ResultCard
  skinType={result.type}
  routine={result.routine}
        onRestart={() => {
      
          setCurrentQuestion(0);
      
          setAnswers([]);
      
          setShowResult(false);
        }}
     />      

      

            {/* Restart */}
            <button
              onClick={() => {

                setCurrentQuestion(0);

                setAnswers([]);

                setShowResult(false);
              }}
              className="w-full mt-10 bg-blue-600 hover:bg-blue-700 text-white py-4 rounded-2xl text-lg font-semibold transition duration-300"
            >

              Retake Quiz

            </button>

          </>

        )}

      </div>

    </section>
  );
}

export default SkinQuiz;