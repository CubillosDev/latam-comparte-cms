export interface RecordFields {
    CreatedAt: Date;
    UpdatedAt: Date;
}

export type RowRecord<TRecord> = TRecord & RecordFields;