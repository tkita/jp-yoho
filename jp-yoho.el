;;; jp-yoho.el --- 気象庁 http://www.jma.go.jp/jp/yoho/ から府県天気予報を取得

;; Copyright (C) 2020 Tsuyoshi Kitamoto <tsuyoshi.kitamoto@gmail.com>

;; Author: Tsuyoshi Kitamoto <tsuyoshi.kitamoto@gmail.com>
;; Maintainer: Tsuyoshi Kitamoto <tsuyoshi.kitamoto@gmail.com>
;; URL: https://github.com/tkita/jp-yoho

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:
;; 

;; Using `jp-yoho':
;;   (jp-yoho)
;;   => "19日17時札幌管区気象台発表の天気予報(今日19日から明後日21日まで) 石狩地方 今夜19日 曇り時々晴れ 明日20日 曇り時々晴れ 明後日21日 曇り時々晴れ"

;;; Code:
(defvar jp-yoho-version "0.1")

(defconst jp-yoho--alist-fuken
  '(("宗谷地方"             . "301 宗谷地方")
    ("上川・留萌地方"       . "302 上川地方 留萌地方")
    ("網走・北見・紋別地方" . "303 網走地方 北見地方 紋別地方")
    ("釧路・根室・十勝地方" . "304 根室地方 釧路地方 十勝地方")
    ("胆振・日高地方"       . "305 胆振地方 日高地方")
    ("石狩・空知・後志地方" . "306 石狩地方 空知地方 後志地方")
    ("渡島・檜山地方"       . "307 渡島地方 檜山地方")
    ("青森県"   . "308 津軽 下北 三八上北")
    ("秋田県"   . "309 沿岸 内陸")
    ("岩手県"   . "310 内陸 沿岸北部 沿岸南部")
    ("山形県"   . "311 村山 置賜 庄内 最上")
    ("宮城県"   . "312 東部 西部")
    ("福島県"   . "313 中通り 浜通り 会津")
    ("茨城県"   . "314 北部 南部")
    ("群馬県"   . "315 南部 北部")
    ("栃木県"   . "316 南部 北部")
    ("埼玉県"   . "317 南部 北部 秩父地方")
    ("千葉県"   . "318 北西部 北東部 南部")
    ("東京都"   . "319 東京地方 伊豆諸島北部 伊豆諸島南部 小笠原諸島")
    ("神奈川県" . "320 東部 西部")
    ("山梨県"   . "321 中･西部 東部･富士五湖")
    ("長野県"   . "322 北部 中部 南部")
    ("新潟県"   . "323 下越 中越 上越 佐渡")
    ("富山県"   . "324 東部 西部")
    ("石川県"   . "325 加賀 能登")
    ("福井県"   . "326 嶺北 嶺南")
    ("静岡県"   . "327 中部 伊豆 東部 西部")
    ("岐阜県"   . "328 美濃地方 飛騨地方")
    ("愛知県"   . "329 西部 東部")
    ("三重県"   . "330 北中部 南部")
    ("大阪府"   . "331 大阪府")
    ("兵庫県"   . "332 南部 北部")
    ("京都府"   . "333 南部 北部")
    ("滋賀県"   . "334 南部 北部")
    ("奈良県"   . "335 北部 南部")
    ("和歌山県" . "336 北部 南部")
    ("島根県"   . "337 東部 西部 隠岐")
    ("広島県"   . "338 南部 北部")
    ("鳥取県"   . "339 東部 中･西部")
    ("岡山県"   . "340 南部 北部")
    ("香川県"   . "341 香川県")
    ("愛媛県"   . "342 中予 東予 南予")
    ("徳島県"   . "343 北部 南部")
    ("高知県"   . "344 中部 東部 西部")
    ("山口県"   . "345 西部 中部 東部 北部")
    ("福岡県"   . "346 福岡地方 北九州地方 筑豊地方 筑後地方")
    ("佐賀県"   . "347 南部 北部")
    ("長崎県"   . "348 南部 北部 壱岐･対馬 五島")
    ("熊本県"   . "349 熊本地方 阿蘇地方 天草･芦北地方 球磨地方")
    ("大分県"   . "350 中部 北部 西部 南部")
    ("宮崎県"   . "351 南部平野部 北部平野部 南部山沿い 北部山沿い")
    ("鹿児島県" . "352 薩摩地方 大隅地方 種子島地方･屋久島地方 奄美地方")
    ("沖縄本島地方" . "353 本島中南部 本島北部 久米島")
    ("大東島地方"   . "354 大東島地方")
    ("宮古島地方"   . "355 宮古島地方")
    ("八重山地方"   . "356 石垣島地方 与那国島地方")))

(defvar jp-yoho-fuken "石狩・空知・後志地方"
  "取得する「府県」")

(defvar jp-yoho-area "石狩地方"
  "取得する「方面」")

(defun jp-yoho-get-url (fuken area)
  "連想リスト `jp-yoho--alist-fuken' を検索し、リスト（ページ番号、tr 位置）を返す."
  ;; => ("303" 1)
  (let* ((list (split-string (cdr (assoc fuken jp-yoho--alist-fuken))))
         (len (length list))
         (res-len (length (member area list))))
    ;; local var `list' => ("303" "網走地方" "北見地方" "紋別地方")
    (list (car list)
          (- len res-len 1))))

(defun jp-yoho--get-dom (page)
  ;; 毎日 5時, 11時, 17時に更新される
  (let* ((url (format "%s%s.html"
                      "http://www.jma.go.jp/jp/yoho/" page))
         (buffer (url-retrieve-synchronously url))
         (dom (with-current-buffer buffer
                (libxml-parse-html-region (point-min) (point-max)))))
    (kill-buffer buffer)
    dom))

(defun jp-yoho--get-yoho-yoho (td)
  (cdr (nth 3 (nth 1 (nth 4 td)))))

(defun jp-yoho--get-yoho (list-dom area-num)
  (let* ((table (nth 3 (nth 16 (nth 5 (nth 26 (nth 2 list-dom))))))
         (date-time (nth 2 (nth 2 table)))
         (n (+ 4 (* 4 area-num))) ; 4, 8, 12, 16, ...
         (local-name (nth 2 (nth 2 (nth 2 (nth n table))))) ; 4
         (tr1 (nth 2 (nth (+ 1 n) table)))                  ; 5
         (today (nth 2 tr1))
         (today-yoho (jp-yoho--get-yoho-yoho tr1))
         (tr2 (nth 2 (nth (+ 2 n) table)))                  ; 6
         (tommorrow (nth 2 tr2))
         (tommorrow-yoho (jp-yoho--get-yoho-yoho tr2))
         (tr3 (nth 2 (nth (+ 3 n) table)))                  ; 7
         (after-tomorrow (nth 2 tr3))
         (after-tomorrow-yoho (jp-yoho--get-yoho-yoho tr3))
         (result (list date-time local-name today today-yoho tommorrow tommorrow-yoho)))

    ;; 「明後日分は週間予報へ」として存在しないときがある
    (when after-tomorrow-yoho
      (setq result (append result
                           (list after-tomorrow after-tomorrow-yoho))))
    (mapconcat (lambda (str)
                 (replace-regexp-in-string "\n" "" str))
               result " ") ))

(defun jp-yoho ()
  (let* ((list (jp-yoho-get-url jp-yoho-fuken jp-yoho-area))
         (page (car list))
         (area-num (car (cdr list)))
         (dom (jp-yoho--get-dom page)))
    (jp-yoho--get-yoho dom area-num)))

(defun jp-yoho/calender-ad (&optional arg)
  (let* ((yoho (jp-yoho))
         (msg (split-string (replace-regexp-in-string "(.*)" "" yoho))))
    (message "%s %s  %s=%s  %s=%s" (nth 1 msg) (nth 0 msg)
             (nth 2 msg) (nth 3 msg)
             (nth 4 msg) (nth 5 msg))))

;; (advice-add 'calendar :after 'jp-yoho/calender-ad)

(defun jp-yoho/fancy-screen-ad (&optional arg)
  (with-current-buffer (get-buffer "*GNU Emacs*")
    (let* ((yoho (jp-yoho))
           (msg (split-string (replace-regexp-in-string "(.*)" "" yoho)))
           string buffer-read-only)
      (goto-char (point-max))
      (setq string (format "\n\n%s %s\n  %s %s\n  %s %s"
                           (nth 1 msg) (nth 0 msg)
                           (nth 2 msg) (nth 3 msg)
                           (nth 4 msg) (nth 5 msg)))
      (when (nth 7 msg)
        (setq string (format "%s\n  %s %s" string (nth 6 msg) (nth 7 msg))))
      (insert string)
      (goto-char (point-min))
      (forward-line 3))))

;; (advice-add 'fancy-startup-screen :after 'jp-yoho/fancy-screen-ad)
;; (advice-remove 'fancy-about-screen 'jp-yoho/fancy-screen-ad)

(provide 'jp-yoho)

;;; jp-yoho.el ends here
