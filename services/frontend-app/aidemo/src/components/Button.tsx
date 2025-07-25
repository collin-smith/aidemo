// Button.tsx
import React from 'react';

interface ButtonProps {
  type: string,
  label: string;
  onClick: () => void;
}

const Button: React.FC<ButtonProps> = ({ type, label, onClick }) => {

  let btnClass = "btn-"+type

  return <button onClick={onClick} className={btnClass}>{label}</button>;
};

export default Button;