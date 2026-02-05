CREATE TABLE "notice_reads" (
	"id" serial PRIMARY KEY NOT NULL,
	"notice_id" integer NOT NULL,
	"user_id" integer NOT NULL,
	"read_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "notice_reads_notice_id_user_id_unique" UNIQUE("notice_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "notices" (
	"id" serial PRIMARY KEY NOT NULL,
	"app_code" varchar(50) NOT NULL,
	"title" varchar(200) NOT NULL,
	"content" text NOT NULL,
	"category" varchar(50),
	"is_pinned" boolean DEFAULT false NOT NULL,
	"view_count" integer DEFAULT 0 NOT NULL,
	"author_id" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"deleted_at" timestamp
);
--> statement-breakpoint
CREATE INDEX "idx_notice_reads_user_id" ON "notice_reads" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_notice_reads_notice_id" ON "notice_reads" USING btree ("notice_id");--> statement-breakpoint
CREATE INDEX "idx_notices_app_code" ON "notices" USING btree ("app_code");--> statement-breakpoint
CREATE INDEX "idx_notices_is_pinned" ON "notices" USING btree ("is_pinned");--> statement-breakpoint
CREATE INDEX "idx_notices_deleted_at" ON "notices" USING btree ("deleted_at");--> statement-breakpoint
CREATE INDEX "idx_notices_created_at" ON "notices" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_notices_category" ON "notices" USING btree ("category");