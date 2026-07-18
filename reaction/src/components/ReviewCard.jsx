import { FaStar } from "react-icons/fa";

function ReviewCard({
  image,
  name,
  role,
  review,
  rating,
}) {

  return (

    <div className="bg-white p-8 rounded-3xl shadow-md hover:shadow-xl transition duration-300">

      {/* Stars */}
      <div className="flex gap-1 text-yellow-400 mb-5">

        {[...Array(rating)].map((_, index) => (

          <FaStar key={index} />

        ))}

      </div>

      {/* Review */}
      <p className="text-gray-600 leading-8 mb-6">
        {review}
      </p>

      {/* User */}
      <div className="flex items-center gap-4">

        <img
          src={image}
          alt={name}
          className="w-14 h-14 rounded-full object-cover"
        />

        <div>

          <h4 className="font-semibold text-gray-900">
            {name}
          </h4>

          <p className="text-sm text-gray-500">
            {role}
          </p>

        </div>

      </div>

    </div>
  );
}

export default ReviewCard;