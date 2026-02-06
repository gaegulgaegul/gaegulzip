"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { noticeApi, Notice } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";

export default function EditNoticePage() {
  const router = useRouter();
  const params = useParams();
  const id = Number(params.id);

  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [category, setCategory] = useState("");
  const [isPinned, setIsPinned] = useState(false);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (Number.isNaN(id)) {
      router.push("/notices");
      return;
    }
    async function load() {
      try {
        const notice: Notice = await noticeApi.getById(id);
        setTitle(notice.title);
        setContent(notice.content);
        setCategory(notice.category ?? "");
        setIsPinned(notice.isPinned);
      } catch {
        setError("공지사항을 불러오는데 실패했습니다.");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [id, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await noticeApi.update(id, {
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

  if (loading) {
    return <p className="text-muted-foreground">불러오는 중...</p>;
  }

  if (error) {
    return <p className="text-destructive">{error}</p>;
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-6 text-2xl font-bold">공지사항 수정</h1>

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
