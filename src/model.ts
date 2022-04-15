class PlainArticle{
  firstPublished?: number;
  title: string;
  subtitle: string;
  type: string;
  tags: string[];
  series: string;
  body: Body[] = [];
}

interface Body{
  [key: string]: string;
}

export default PlainArticle;