// components/Auth.jsx

import { useState } from "react";
import { FcGoogle } from "react-icons/fc";
import { signInWithGoogle } from "../firebase/firebase";

function Auth({ setShowAuth, setUser }) {

  const [showUpload, setShowUpload] = useState(false);

const [selectedImage, setSelectedImage] = useState(null);

const handleGoogleLogin = async () => {

  try {

    const user =
      await signInWithGoogle();

    if(user){

      // IF GOOGLE HAS NO PHOTO
      if(!user.photoURL){

        localStorage.setItem(
          "tempUser",
          JSON.stringify({
            name: user.displayName,
            email: user.email,
          })
        );

        setShowUpload(true);

        return;
      }

      // NORMAL LOGIN
      const userData = {
        name: user.displayName,
        email: user.email,
        photo: user.photoURL,
      };

      localStorage.setItem(
        "user",
        JSON.stringify(userData)
      );

      setUser(userData);

      setShowAuth(false);
    }

  } catch (error) {

    console.log(error);
  }
};

  return (

    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 px-5">

      {/* Modal */}
      <div className="w-full max-w-md bg-white rounded-[30px] p-8 md:p-10 relative shadow-2xl">

        {/* Close Button */}
        <button
          onClick={() => setShowAuth(false)}
          className="absolute top-5 right-5 text-3xl text-gray-400 hover:text-black transition"
        >
          ×
        </button>

        {/* Heading */}
        <div className="text-center">

          <p className="text-blue-600 font-semibold mb-3">
            Secure Authentication
          </p>

          <h2 className="text-4xl font-bold text-gray-900 leading-tight">
            Welcome Back
          </h2>

          <p className="text-gray-500 mt-5 leading-7">
            Continue with Google to access your
            personalized healthcare dashboard.
          </p>

        </div>

        {/* Google Button */}
        <button
          onClick={handleGoogleLogin}
          className="w-full mt-10 flex items-center justify-center gap-4 border border-gray-300 hover:border-blue-500 hover:shadow-lg transition duration-300 rounded-2xl py-4 text-lg font-medium text-gray-700"
        >

          <FcGoogle className="text-3xl" />

          Continue with Google

        </button>

        {/* Upload Profile Picture */}

{showUpload && (

  <div className="mt-8">

    <p className="mb-4 text-gray-600">
      Add Profile Picture
    </p>

    <input
      type="file"
      accept="image/*"
      onChange={(e) => {

        const file =
          e.target.files[0];

        const imageUrl =
          URL.createObjectURL(file);

        setSelectedImage(imageUrl);
      }}
      className="w-full border border-gray-300 rounded-xl p-3"
    />

    <button
      onClick={() => {

  if(!selectedImage){

    alert("Please upload profile picture");

    return;
  }

  const tempUser = JSON.parse(
    localStorage.getItem("tempUser")
  );

  const userData = {
    ...tempUser,
    photo: selectedImage,
  };

  localStorage.setItem(
    "user",
    JSON.stringify(userData)
  );

  setUser(userData);

  localStorage.removeItem(
    "tempUser"
  );

  setShowAuth(false);
}}
      className="w-full mt-5 bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-xl"
    >
      Continue
    </button>

  </div>

)}

        {/* Terms */}
        <p className="text-sm text-gray-400 text-center mt-8 leading-6">
          By continuing, you agree to our
          Terms of Service and Privacy Policy.
        </p>

      </div>

    </div>
  );
}

export default Auth;