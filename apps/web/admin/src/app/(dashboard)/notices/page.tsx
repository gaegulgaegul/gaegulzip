"use client";

import { useEffect, useState, useCallback } from "react";
import { useRouter } from "next/navigation";
import { noticeApi, NoticeSummary, NoticeListResponse } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

export default function NoticesPage() {
  const router = useRouter();
  const [data, setData] = useState<NoticeListResponse | null>(null);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<NoticeSummary | null>(null);

  const fetchNotices = useCallback(async () => {
    setLoading(true);
    const result = await noticeApi.list(page);
    setData(result);
    setLoading(false);
  }, [page]);

  useEffect(() => {
    fetchNotices();
  }, [fetchNotices]);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    await noticeApi.remove(deleteTarget.id);
    setDeleteTarget(null);
    fetchNotices();
  };

  const handleTogglePin = async (notice: NoticeSummary) => {
    await noticeApi.togglePin(notice.id, !notice.isPinned);
    fetchNotices();
  };

  // TODO(human): 날짜 포맷 유틸리티
  const formatDate = (iso: string) => {
    return new Date(iso).toLocaleDateString("ko-KR", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
  };

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">공지사항 관리</h1>
          <p className="mt-1 text-muted-foreground">
            공지사항을 작성하고 관리합니다.
          </p>
        </div>
        <Button onClick={() => router.push("/notices/new")}>
          새 공지 작성
        </Button>
      </div>

      {loading ? (
        <p className="text-muted-foreground">불러오는 중...</p>
      ) : (
        <>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">ID</TableHead>
                <TableHead>제목</TableHead>
                <TableHead className="w-24">카테고리</TableHead>
                <TableHead className="w-16">고정</TableHead>
                <TableHead className="w-20">조회수</TableHead>
                <TableHead className="w-28">생성일</TableHead>
                <TableHead className="w-20">삭제</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.items.map((notice) => (
                <TableRow
                  key={notice.id}
                  className="cursor-pointer"
                  onClick={() => router.push(`/notices/${notice.id}/edit`)}
                >
                  <TableCell>{notice.id}</TableCell>
                  <TableCell className="font-medium">{notice.title}</TableCell>
                  <TableCell>
                    {notice.category ? (
                      <Badge variant="secondary">{notice.category}</Badge>
                    ) : (
                      "-"
                    )}
                  </TableCell>
                  <TableCell onClick={(e) => e.stopPropagation()}>
                    <Switch
                      checked={notice.isPinned}
                      onCheckedChange={() => handleTogglePin(notice)}
                    />
                  </TableCell>
                  <TableCell>{notice.viewCount}</TableCell>
                  <TableCell>{formatDate(notice.createdAt)}</TableCell>
                  <TableCell onClick={(e) => e.stopPropagation()}>
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => setDeleteTarget(notice)}
                    >
                      삭제
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
              {data?.items.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="text-center text-muted-foreground">
                    공지사항이 없습니다.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>

          <div className="mt-4 flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              총 {data?.totalCount ?? 0}건
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage((p) => p - 1)}
              >
                이전
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={!data?.hasNext}
                onClick={() => setPage((p) => p + 1)}
              >
                다음
              </Button>
            </div>
          </div>
        </>
      )}

      <AlertDialog open={!!deleteTarget} onOpenChange={() => setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>공지사항 삭제</AlertDialogTitle>
            <AlertDialogDescription>
              &quot;{deleteTarget?.title}&quot;을(를) 삭제하시겠습니까? 이 작업은
              되돌릴 수 없습니다.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>취소</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>삭제</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
