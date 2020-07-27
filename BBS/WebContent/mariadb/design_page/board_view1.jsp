<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>

<%@ page import="javax.sql.DataSource" %>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%
	request.setCharacterEncoding("utf-8");

	String cpage = request.getParameter("cpage");
	String seq = request.getParameter("seq");
	
	String subject = "";
	String writer = "";
	String mail = "";
	String wip = "";
	String wdate = "";
	String hit = "";
	String content = "";
	String emot = "";
	String file = "";

	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup("java:comp/env");
		DataSource dataSource = (DataSource)envCtx.lookup("jdbc/mariadb1");
		
		conn = dataSource.getConnection();
		
		String sql ="update board1 set hit=hit+1 where seq=" + seq;
		pstmt = conn.prepareStatement(sql);
		pstmt.executeUpdate();
		pstmt.close();
				
		sql = "select subject, writer, mail, wip, wdate, hit, content, emot, filename, format(filesize,0) filesize from board1 where seq="+ seq;
		pstmt = conn.prepareStatement(sql);
		rs = pstmt.executeQuery(sql);
		
		if (rs.next()) {
			subject = rs.getString("subject");
			writer = rs.getString("writer");
			mail = rs.getString("mail");
			wip = rs.getString("wip");
			wdate = rs.getString("wdate");
			hit = rs.getString("hit");
			content = rs.getString("content").replaceAll("\n", "<br>");
			emot = rs.getString("emot");
			if (!rs.getString("filesize").equals("0")) {
				file = "<a href='./download.jsp?filename=" + rs.getString("filename") + "'>" + rs.getString("filename") + "</a>(" + rs.getString("filesize") + "byte" + ")";
			}
		}
	} catch (NamingException e) {
		System.out.println("[에러] : " + e.getMessage());
	} catch (SQLException e) {
		System.out.println("[에러] : " + e.getMessage());
	} finally {
		if (rs != null) rs.close();
		if (pstmt != null) pstmt.close();
		if (conn != null) conn.close();
	}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>JSP 게시판</title>
<link rel="stylesheet" type="text/css" href="../../css/board_view.css">
</head>

<body>
<div class="con_title">
	<h3>게시판</h3>
	<p>HOME &gt; 게시판 &gt; <strong>게시판</strong></p>
</div>
<div class="con_txt">
	<div class="contents_sub">
		<!--게시판-->
		<div class="board_view">
			<table>
				<tr>
					<th width="10%">제목</th>
					<td width="60%">(<img src="../../images/emoticon/emot<%=emot %>.png" width="15"/>)&nbsp;<%=subject %></td>
					<th width="10%">등록일</th>
					<td width="20%"><%=wdate %></td>
				</tr>
				<tr>
					<th>글쓴이</th>
					<td><%=writer %>(<%=mail %>)(<%=wip %>)</td>
					<th>조회</th>
					<td><%=hit %></td>
				</tr>
				<tr>
					<th>첨부 파일</th>
					<td><%=file %></td>
					<th></th>
					<td></td>
				</tr>
				<tr>
					<td colspan="4" height="200" valign="top" style="padding: 20px; line-height: 160%"><%=content %></td>
				</tr>
			</table>
		</div>

		<div class="btn_area">
			<div class="align_left">
				<input type="button" value="목록" class="btn_list btn_txt02" style="cursor: pointer;" onclick="location.href='board_list1.jsp?cpage=<%=cpage %>'" />
			</div>
<%
	if (session.getAttribute("s_id") == null || session.getAttribute("s_grade") == null) {
		//로그인 안한 상태
%>	
<%	
	} else {
		//로그인 상태
%>	
			<div class="align_right">
				<input type="button" value="수정" class="btn_list btn_txt02" style="cursor: pointer;" onclick="location.href='board_modify1.jsp?cpage=<%=cpage %>&seq=<%=seq %>'" />
				<input type="button" value="삭제" class="btn_list btn_txt02" style="cursor: pointer;" onclick="location.href='board_delete1.jsp?cpage=<%=cpage %>&seq=<%=seq %>'" />
				<input type="button" value="답변글" class="btn_write btn_txt01" style="cursor: pointer;" onclick="location.href='board_reply1.jsp?cpage=<%=cpage %>&seq=<%=seq %>'" />
				<input type="button" value="쓰기" class="btn_write btn_txt01" style="cursor: pointer;" onclick="location.href='board_write1.jsp?cpage=<%=cpage %>'" />
			</div>
<%
	}
%>
		</div>	
		<!--//게시판-->
	</div>
</div>

</body>
</html>
