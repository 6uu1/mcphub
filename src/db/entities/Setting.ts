import { Entity, PrimaryColumn, Column, UpdateDateColumn } from 'typeorm';

/**
 * 持久化存储 mcp_settings.json 的完整内容，避免 Render 等平台磁盘重置导致数据丢失。
 * 仅保留一行（id = 1）。
 */
@Entity('settings')
export class Setting {
  /** 固定为 1，始终只有一行数据 */
  @PrimaryColumn()
  id!: number;

  /** 完整配置 JSON */
  @Column({ type: 'jsonb', default: {} })
  data!: any;

  /** 更新时间戳 */
  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt!: Date;
} 