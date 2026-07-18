import { FcGoogle } from "react-icons/fc";
import { signInWithGoogle } from "../firebase/firebase";

function Auth({setShowAuth, setUser }) {

const handleGoogleLogin = async () => {

  try {

    const user = await signInWithGoogle();

    if (user) {

      const userData = {
        name: user.displayName,
        email: user.email,
        photo: user.photoURL,
      };

      localStorage.setItem(
        "user",
        JSON.stringify(userData)
      );

      if(setUser){
        setUser(userData);
      }

      setShowAuth(false);
    }

  } catch (error) {

    console.error(error);
  }
};

  return (

    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 px-5">

      <div className="w-full max-w-xl bg-white rounded-[30px] p-10 shadow-2xl relative text-center">

        {/* Close Button */}
        <button
          onClick={() => setShowAuth(false)}
          className="absolute top-5 right-6 text-3xl text-gray-400 hover:text-black"
        >
          ×
        </button>

        <h2 className="text-4xl font-bold text-gray-900 mb-4">
          Continue With Google
        </h2>

        <p className="text-gray-600 leading-8 mb-10">
          Securely sign in and access your
          personalized healthcare dashboard.
        </p>
        
<button
  onClick={async () => {

    try {

      const user =
        await signInWithGoogle();

      console.log(user);

    } catch (error) {

      console.error(error);
    }
  }}
  className="w-full flex items-center justify-center gap-4 bg-white border border-gray-300 hover:border-blue-500 hover:shadow-lg py-4 rounded-2xl text-lg font-medium transition duration-300"
>

  <FcGoogle className="text-3xl" />

  Sign In With Google

</button>

      </div>

    </div>
  );
}

export default Auth;