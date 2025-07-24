import React from 'react';

function GroupBubble({ group, onClick }) {
  return (
    <div
      className="cursor-pointer rounded-full px-6 py-3 m-2 text-white bg-blue-500 hover:bg-blue-600 shadow-lg text-center text-sm sm:text-base"
      onClick={() => onClick(group)}
    >
      {group.Name}
    </div>
  );
}

export default GroupBubble;
