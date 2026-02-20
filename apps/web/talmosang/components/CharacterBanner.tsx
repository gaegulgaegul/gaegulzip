/**
 * 캐릭터 배너 컴포넌트
 *
 * 4개 캐릭터가 합쳐진 단일 SVG 이미지를 하단에 좌우 꽉 채워 배치합니다.
 * 하단에 두꺼운 검정 테두리를 추가합니다.
 */
export default function CharacterBanner() {
  return (
    <div className="w-full mt-auto pointer-events-none border-b-[8px] border-black">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src="/characters.svg"
        alt="탈모상 캐릭터들 - 빡도사, 킹, 동구, MJ아트"
        className="w-full block"
      />
    </div>
  );
}
