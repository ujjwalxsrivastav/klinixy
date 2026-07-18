// components/DietitianWidget.jsx

import { useState } from "react";
import { FaUserDoctor } from "react-icons/fa6";

function DietitianWidget() {

  const [open, setOpen] =
    useState(false);

  const [message, setMessage] =
    useState("");

  const [messages, setMessages] =
    useState([
      {
        sender: "doctor",
        text: "Hello 👋 I am Dr. Sarah. How can I help you today?",
      },
    ]);

  const handleSendMessage = () => {

    if(!message) return;

    setMessages([
      ...messages,
      {
        sender: "user",
        text: message,
      },
    ]);

    setMessage("");

    // Fake doctor reply
    setTimeout(() => {

      setMessages((prev) => [
        ...prev,
        {
          sender: "doctor",
          text: "Thank you for your message. Our dietitian will guide you shortly.",
        },
      ]);

    }, 1000);
  };

  return (

    <>

      {/* Floating Button */}
      <button
  onClick={() => setOpen(!open)}
  className="fixed bottom-6 right-6 z-50 bg-blue-600 hover:bg-blue-700 w-16 h-16 rounded-full shadow-2xl text-white text-3xl flex items-center justify-center transition duration-300"
>
  <FaUserDoctor size={28} />
</button>

      {/* Chat Window */}
      {open && (

        <div className="fixed bottom-24 right-6 w-[360px] h-[550px] bg-white rounded-[30px] shadow-2xl overflow-hidden z-50 border border-gray-200">

          {/* Header */}
          <div className="bg-blue-600 p-5 flex items-center gap-4 text-white">

            <img
              src="https://randomuser.me/api/portraits/women/65.jpg"
              alt="doctor"
              className="w-14 h-14 rounded-full object-cover border-2 border-white"
            />

            <div>

              <h3 className="font-semibold text-lg">
                Dr. Sarah Wilson
              </h3>

              <p className="text-sm text-blue-100">
                Dietitian • Online
              </p>

            </div>

          </div>

          {/* Messages */}
          <div className="flex-1 h-[360px] overflow-y-auto p-5 bg-gray-50 space-y-4">

            {messages.map((msg, index) => (

              <div
                key={index}
                className={`max-w-[80%] px-4 py-3 rounded-2xl text-sm leading-6 ${
                  msg.sender === "user"
                    ? "bg-blue-600 text-white ml-auto"
                    : "bg-white text-gray-700 shadow-sm"
                }`}
              >

                {msg.text}

              </div>

            ))}

          </div>

          {/* Input */}
          <div className="p-4 border-t border-gray-200 bg-white flex gap-3">

            <input
              type="text"
              value={message}
              onChange={(e) =>
                setMessage(e.target.value)
              }
              placeholder="Type your message..."
              className="flex-1 border border-gray-300 rounded-xl px-4 outline-none focus:border-blue-500"
            />

            <button
              onClick={handleSendMessage}
              className="bg-blue-600 hover:bg-blue-700 text-white px-5 rounded-xl transition duration-300"
            >

              Send

            </button>

          </div>

        </div>

      )}

    </>
  );
}

export default DietitianWidget;