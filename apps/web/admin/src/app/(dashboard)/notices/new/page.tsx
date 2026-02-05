"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { noticeApi } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";

export default function NewNoticePage() {
  const router = useRouter();
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [category, setCategory] = useState("");
  const [isPinned, setIsPinned] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await noticeApi.create({
        title,
        content,
        category: category || undefined,
        isPinned,
      });
      router.push("/notices");
    } catch {
      alert("저장에 실패했습니다. 다시 시도해주세요.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-6 text-2xl font-bold">새 공지 작성</h1>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="space-y-2">
          <Label htmlFor="title">제목</Label>
          <Input
            id="title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="공지사항 제목을 입력하세요"
            required
            maxLength={200}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="content">본문</Label>
          <Textarea
            id="content"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="공지사항 본문을 입력하세요 (마크다운 지원)"
            required
            rows={10}
          />
        </div>

        <div className="space-y-2">
          <Label htmlFor="category">카테고리 (선택)</Label>
          <Input
            id="category"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            placeholder="예: update, event, maintenance"
            maxLength={50}
          />
        </div>

        <div className="flex items-center gap-3">
          <Switch
            id="isPinned"
            checked={isPinned}
            onCheckedChange={setIsPinned}
          />
          <Label htmlFor="isPinned">상단 고정</Label>
        </div>

        <div className="flex gap-3">
          <Button type="submit" disabled={submitting}>
            {submitting ? "저장 중..." : "저장"}
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={() => router.push("/notices")}
          >
            취소
          </Button>
        </div>
      </form>
    </div>
  );
}
