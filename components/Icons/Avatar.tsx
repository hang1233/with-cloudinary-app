import Image from 'next/image';
import touxiangImage from '../../touxiang/1.png';

export default function Avatar() {
  return (
    <div className="relative w-48 h-48 overflow-hidden rounded-full border-4 border-white/30 shadow-lg">
      <div className="absolute inset-0">
        <Image
          src={touxiangImage}
          alt="郭子骁头像"
          fill
          sizes="192px"
          className="object-cover"
          priority
        />
      </div>
    </div>
  );
} 