import { initializeApp } from "firebase/app";

import {
  getAuth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut
} from "firebase/auth";

import {
  getFirestore,
} from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAPy2UsDcFVdQCFB7h_v6X7dDMq3IWw2BM",
  authDomain: "klinixy-2020a.firebaseapp.com",
  projectId: "klinixy-2020a",
  storageBucket: "klinixy-2020a.firebasestorage.app",
  messagingSenderId: "597071279913",
  appId: "1:597071279913:web:6608b7f47a910472d66938",
  measurementId: "G-T7EBTKPLZN"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);

export const provider =
  new GoogleAuthProvider();

export const db =
  getFirestore(app);

export const signInWithGoogle =
  async () => {

    try {

      const result =
        await signInWithPopup(
          auth,
          provider
        );

      return result.user;

    } catch (error) {

      console.log(error);
    }
};

export const logout = async () => {

  try {

    await signOut(auth);

    localStorage.removeItem("user");

  } catch (error) {

    console.log(error);
  }
};