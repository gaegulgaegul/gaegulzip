CREATE TABLE "push_notification_receipts" (
	"id" serial PRIMARY KEY NOT NULL,
	"app_id" integer NOT NULL,
	"user_id" integer NOT NULL,
	"alert_id" integer NOT NULL,
	"title" varchar(255) NOT NULL,
	"body" varchar(1000) NOT NULL,
	"data" jsonb DEFAULT '{}'::jsonb,
	"image_url" varchar(500),
	"is_read" boolean DEFAULT false NOT NULL,
	"read_at" timestamp,
	"received_at" timestamp DEFAULT now() NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX "idx_push_notification_receipts_app_id" ON "push_notification_receipts" USING btree ("app_id");--> statement-breakpoint
CREATE INDEX "idx_push_notification_receipts_user_id" ON "push_notification_receipts" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_push_notification_receipts_alert_id" ON "push_notification_receipts" USING btree ("alert_id");--> statement-breakpoint
CREATE INDEX "idx_push_notification_receipts_is_read" ON "push_notification_receipts" USING btree ("is_read");--> statement-breakpoint
CREATE INDEX "idx_push_notification_receipts_received_at" ON "push_notification_receipts" USING btree ("received_at");--> statement-breakpoint
CREATE INDEX "idx_push_notification_receipts_user_app_received" ON "push_notification_receipts" USING btree ("user_id","app_id","received_at");