import Link from "next/link";
import Image from "next/image";
import formatTimestamp from "../utils/formatTimestamp";

interface Props {
  id: string;
  name: string;
  eventTimestamp: number;
  imageURL?: string;
}

export default function EventCard({
  id,
  name,
  eventTimestamp,
  imageURL,
}: Props) {
  return (
    <div className="group relative clickable-card rounded-lg focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-offset-gray-100 focus-within:ring-indigo-500">
      <Link href={`/event/${id}`} className="clickable-card__link">
        <div className="block w-full aspect-w-10 aspect-h-7 rounded-lg bg-gray-100 overflow-hidden relative group-hover:opacity-75">
          {imageURL && (
            <Image src={imageURL} alt="event image" width={500} height={500} />
          )}
        </div>
      </Link>
      <p className="mt-2 block text-sm text-gray-500">
        {formatTimestamp(eventTimestamp)}
      </p>
      <p className="block text-base font-medium text-gray-900">{name}</p>
    </div>
  );
}
