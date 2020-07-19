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

<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="java.io.File" %>
<%
	request.setCharacterEncoding("utf-8");
	
	//cpage 값이 넘어오면 받고 아니면 1로 세팅
	int cpage = 1;
	if (request.getParameter("cpage") != null && !request.getParameter("cpage").equals("")) {
		cpage = Integer.parseInt(request.getParameter("cpage"));
	}
	
	//전체 데이터 개수
	int totalRecord = 0;
	
	//전체 페이지 개수
	int totalPage = 1;
	
	//페이지당 출력될 데이터 개수
	int recordPerPage = 10;
	
	//페이지당 나타낼 버튼이동할 수 있는 페이지 개수
	int blockPerPage = 5;
	
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	//DB 게시글 불러오기
	StringBuffer strHtml = new StringBuffer();
	try {
		Context initCtx = new InitialContext();
		Context envCtx = (Context)initCtx.lookup("java:comp/env");
		DataSource dataSource = (DataSource)envCtx.lookup("jdbc/mariadb1");
		
		conn = dataSource.getConnection();
		
		String sql = "select seq, subject, writer, date_format(wdate, '%Y-%m-%d') wdate, hit, datediff(now(), wdate) wgap, filename from board1 order by seq desc";
		pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
		
		rs = pstmt.executeQuery();
		
		rs.last();
		totalRecord = rs.getRow();
		rs.beforeFirst();
		
		totalPage = ((totalRecord - 1) / recordPerPage) + 1;
		
		int skip = (cpage - 1) * recordPerPage;
		if (skip != 0) rs.absolute(skip);
		
		for (int i = 0; i < recordPerPage && rs.next(); i++) {
			String seq = rs.getString("seq");
			String subject = rs.getString("subject");
			String writer = rs.getString("writer");
			String wdate = rs.getString("wdate");
			String hit = rs.getString("hit");
			int wgap = rs.getInt("wgap");
			String filename = rs.getString("filename");
			
			strHtml.append("<tr>");
			strHtml.append("<td>&nbsp;</td>");
			strHtml.append("<td>" + seq + "</td>");
			strHtml.append("<td class='left'>");
			strHtml.append("<a href='board_view1.jsp?cpage="+ cpage +"&seq="+ seq +"'>"+ subject +"</a>");
			if (wgap == 0) strHtml.append("&nbsp;<img src='../../images/icon_hot.gif' alt='HOT'>");
			strHtml.append("</td>");
			strHtml.append("<td>" + writer + "</td>");
			strHtml.append("<td>" + wdate + "</td>");
			strHtml.append("<td>" + hit + "</td>");
			strHtml.append("<td>");
			if (filename != null) strHtml.append("<img src='../../images/icon_file.gif' />");
			strHtml.append("</td>");
			strHtml.append("</tr>");
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
<link rel="stylesheet" type="text/css" href="../../css/board_list.css">
</head>

<body>
<div class="con_title">
	<h3>게시판</h3>
	<p>HOME &gt; 게시판 &gt; <strong>게시판</strong></p>
</div>
<div class="con_txt">
	<div class="contents_sub">
		<div class="board_top">
			<div class="bold">총 <span class="txt_orange"><%=totalRecord %></span>건</div>
		</div>

		<div class="board">
			<table>
			<tr>
				<th width="3%">&nbsp;</th>
				<th width="5%">번호</th>
				<th>제목</th>
				<th width="10%">글쓴이</th>
				<th width="17%">등록일</th>
				<th width="5%">조회</th>
				<th width="3%">&nbsp;</th>
			</tr>
<!-- 게시글 시작 -->
<%= strHtml %>
<!-- 게시글 끝 -->
			</table>
		</div>	
		
		<!--페이지 넘버-->
		<div class="paginate_regular">
<%
	int startBlock = ((cpage - 1) / blockPerPage) * blockPerPage + 1;
	int endBlock = ((cpage - 1) / blockPerPage) * blockPerPage + blockPerPage;
	if (endBlock >= totalPage) {
		endBlock = totalPage;
	}
	// << 버튼 (첫 페이지로 이동)
	if (cpage == 1) {
		out.println("<span><a>&lt;&lt;</a></span>");
	} else {
		out.println("<span><a href='board_list1.jsp?cpage="+ (1) +"'>&lt;&lt;</a></span>");
	}
	// < 버튼 (한 페이지 앞으로 이동)
	if (cpage == 1) {
		out.println("<span><a>&lt;</a></span>");
	} else {
		out.println("<span><a href='board_list1.jsp?cpage="+ (cpage - 1) +"'>&lt;</a></span>");
	}
	out.println("&nbsp;");
%>
<% 
	for (int i = startBlock; i <= endBlock; i++) {
		if (cpage == i) {
			out.println("<span><a>["+ i +"]</a></span>");
		} else {
			out.println("<span><a href='board_list1.jsp?cpage="+ i +"'>"+ i +"</a></span>");
		}
	}
%>
<%	
	// > 버튼 (한 페이지 뒤로 이동)
	out.println("&nbsp;");
	if (cpage == totalPage) {
		out.println("<span><a>&gt;</a></span>");
	} else {
		out.println("<span><a href='board_list1.jsp?cpage="+ (cpage + 1) +"'>&gt;</a></span>");
	}
	// >> 버튼 (마지막 페이지로 이동)
	if (cpage == totalPage) {
		out.println("<span><a>&gt;&gt;</a></span>");
	} else {
		out.println("<span><a href='board_list1.jsp?cpage="+ (totalPage) +"'>&gt;&gt;</a></span>");
	}
%>
		</div>
		<!--//페이지넘버-->
		
		<div class="align_right">
			<input type="button" value="쓰기" class="btn_write btn_txt01" style="cursor: pointer;" onclick="location.href='board_write1.jsp?cpage=<%=cpage %>'" />
		</div>
	</div>
</div>

</body>
</html>
