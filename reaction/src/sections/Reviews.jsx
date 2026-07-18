import { useEffect, useState } from "react";

import {
  collection,
  addDoc,
  getDocs,
  orderBy,
  query,
  deleteDoc,
  doc,
} from "firebase/firestore";

import { db } from "../firebase/firebase";

import { FaStar } from "react-icons/fa";

import ReviewCard from "../components/ReviewCard";

function Reviews() {

  const [reviews, setReviews] = useState([]);

  const [showReviewForm, setShowReviewForm] =
    useState(false);

  const [rating, setRating] =
    useState(0);

  const [reviewText, setReviewText] =
    useState("");

  const user = JSON.parse(
    localStorage.getItem("user")
  );

  // FETCH REVIEWS
  useEffect(() => {

    fetchReviews();

  }, []);

  const fetchReviews = async () => {

    try {

      const q = query(
        collection(db, "reviews"),
        orderBy("createdAt", "desc")
      );

      const querySnapshot =
        await getDocs(q);

      const reviewsData = [];

      querySnapshot.forEach((doc) => {

        reviewsData.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      setReviews(reviewsData);

    } catch (error) {

      console.log(error);
    }
  };

  // SUBMIT REVIEW
  const handleSubmitReview = async () => {

    if (!user) {

      alert("Please sign in first");

      return;
    }

    if (!reviewText || rating === 0) {

      alert("Please add review and rating");

      return;
    }

    try {

      await addDoc(
        collection(db, "reviews"),
        {
          name: user.name,
          photo: user.photo,
           email: user.email,
          review: reviewText,
          rating: rating,
          createdAt: new Date(),
        }
      );

      setShowReviewForm(false);

      setReviewText("");

      setRating(0);

      fetchReviews();

    } catch (error) {

      console.log(error);
    }
  };

  const handleDeleteReview = async (id) => {

  try {

    await deleteDoc(
      doc(db, "reviews", id)
    );

    fetchReviews();

  } catch (error) {

    console.log(error);
  }
};

  return (

    <section
      id="reviews"
      className="w-full px-8 md:px-16 py-24 bg-blue-50"
    >

      {/* Heading */}
      <div className="text-center mb-16">

        <p className="text-blue-600 font-semibold mb-3">
          Testimonials
        </p>

        <h2 className="text-4xl md:text-5xl font-bold text-gray-900">
          What Our Users Say
        </h2>

        <p className="text-gray-600 mt-5 max-w-2xl mx-auto leading-8">
          Thousands of users trust our platform.
        </p>

        <button
          onClick={() =>
            setShowReviewForm(true)
          }
          className="mt-8 bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-2xl transition duration-300 shadow-lg"
        >
          Give Review
        </button>

      </div>

      {/* Reviews */}
     <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">

  {reviews.map((item) => (

    <div key={item.id} className="relative">

      <ReviewCard
        image={item.photo}
        name={item.name}
        role="User"
        review={item.review}
        rating={item.rating}
      />


     {/* Delete Button */}

{user?.email === item.email && (

  <button
    onClick={() =>
      handleDeleteReview(item.id)
    }
    className="absolute top-4 right-4 bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-xl text-sm"
  >
    Delete
  </button>

)}

    </div>

  ))}

</div>

      {/* MODAL */}
      {showReviewForm && (

        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 px-5">

          <div className="bg-white w-full max-w-xl rounded-[30px] p-8 relative shadow-2xl">

            {/* Close */}
            <button
              onClick={() =>
                setShowReviewForm(false)
              }
              className="absolute top-5 right-5 text-2xl"
            >
              ×
            </button>

            <h3 className="text-3xl font-bold mb-3">
              Give Your Review
            </h3>

            {/* Stars */}
            <div className="flex gap-3 mb-8">

              {[1, 2, 3, 4, 5].map((star) => (

                <FaStar
                  key={star}
                  onClick={() =>
                    setRating(star)
                  }
                  className={`text-3xl cursor-pointer ${
                    star <= rating
                      ? "text-yellow-400"
                      : "text-gray-300"
                  }`}
                />

              ))}

            </div>

            {/* Textarea */}
            <textarea
              value={reviewText}
              onChange={(e) =>
                setReviewText(e.target.value)
              }
              placeholder="Write your review..."
              className="w-full h-36 border border-gray-300 rounded-2xl p-5 outline-none"
            />

            {/* Submit */}
            <button
              onClick={handleSubmitReview}
              className="w-full mt-8 bg-blue-600 hover:bg-blue-700 text-white py-4 rounded-2xl text-lg font-semibold"
            >
              Submit Review
            </button>

          </div>

        </div>

      )}

    </section>
  );
}

export default Reviews;