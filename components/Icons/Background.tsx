export default function Background() {
  return (
    <svg
      width="620"
      height="704"
      viewBox="0 0 620 704"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* 简单的相机图标 */}
      <path
        d="M310 250 C260 250, 220 290, 220 340 C220 390, 260 430, 310 430 C360 430, 400 390, 400 340 C400 290, 360 250, 310 250 Z"
        stroke="currentColor"
        strokeWidth="4"
        fill="none"
      />
      <path
        d="M440 200 L440 460 L180 460 L180 200 L270 200 L290 170 L330 170 L350 200 L440 200 Z"
        stroke="currentColor"
        strokeWidth="4"
        fill="none"
      />
      
      {/* 简单的相框 */}
      <rect
        x="200"
        y="520"
        width="220"
        height="150"
        stroke="currentColor"
        strokeWidth="3"
        fill="none"
      />
      <line
        x1="200"
        y1="520"
        x2="420"
        y2="670"
        stroke="currentColor"
        strokeWidth="1"
      />
      <line
        x1="420"
        y1="520"
        x2="200"
        y2="670"
        stroke="currentColor"
        strokeWidth="1"
      />
    </svg>
  );
} 